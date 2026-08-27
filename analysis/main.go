package main

import (
	"bufio"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"math"
	"os"
	"sort"
	"strings"
)

type Frame struct {
	Timestamp string
	Payload   []byte
}

func main() {
	file, err := os.Open("frames.csv")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	const headerLen = 16
	var frames []Frame

	scanner := bufio.NewScanner(file)
	buf := make([]byte, 1024*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, "|")
		if len(parts) < 2 {
			continue
		}
		ts := parts[0]
		b, err := hex.DecodeString(parts[1])
		if err != nil || len(b) <= headerLen {
			continue
		}
		payload := b[headerLen:]
		if len(payload) == 63 && payload[3] == 0x33 {
			frames = append(frames, Frame{ts, payload})
		}
	}
	if err := scanner.Err(); err != nil {
		fmt.Println("scanner error:", err)
	}

	// sort oldest -> newest for monotonic/time-series checks
	sort.Slice(frames, func(i, j int) bool { return frames[i].Timestamp < frames[j].Timestamp })

	fmt.Printf("Loaded %d telemetry frames\n\n", len(frames))
	if len(frames) < 5 {
		return
	}

	// --- Part 1: raw byte table for first 3 frames ---
	fmt.Println("=== First 3 frames, byte-by-byte ===")
	fmt.Printf("offset  ")
	for i := 0; i < 3; i++ {
		fmt.Printf("frame%d ", i+1)
	}
	fmt.Println()
	for i := 0; i < len(frames[0].Payload); i++ {
		fmt.Printf("%3d:    ", i)
		for f := 0; f < 3; f++ {
			fmt.Printf("%02X     ", frames[f].Payload[i])
		}
		fmt.Println()
	}

	// --- Part 2: derived fields for correlation ---
	volt := make([]float64, len(frames))
	curr := make([]float64, len(frames))
	t1 := make([]float64, len(frames))
	t3 := make([]uint16, len(frames))
	for i, f := range frames {
		volt[i] = float64(binary.LittleEndian.Uint16(f.Payload[0:2]))
		curr[i] = float64(binary.LittleEndian.Uint16(f.Payload[4:6]))
		t1[i] = float64(binary.LittleEndian.Uint16(f.Payload[37:39]))
		t3[i] = binary.LittleEndian.Uint16(f.Payload[61:63])
	}

	// --- Part 3: per-byte stats ---
	fmt.Println("\n=== Per-byte analysis ===")
	length := len(frames[0].Payload)
	for offset := 0; offset < length; offset++ {
		vals := make([]float64, len(frames))
		byteVals := make([]byte, len(frames))
		for i, f := range frames {
			byteVals[i] = f.Payload[offset]
			vals[i] = float64(f.Payload[offset])
		}

		minV, maxV := vals[0], vals[0]
		unique := map[byte]bool{}
		for i, v := range vals {
			if v < minV {
				minV = v
			}
			if v > maxV {
				maxV = v
			}
			unique[byteVals[i]] = true
		}

		if len(unique) == 1 {
			fmt.Printf("byte %2d: CONSTANT 0x%02X\n", offset, byteVals[0])
			continue
		}

		// monotonic check (allow wraparound tolerance: count non-decreasing steps)
		nonDec, nonInc := 0, 0
		for i := 1; i < len(vals); i++ {
			if vals[i] >= vals[i-1] {
				nonDec++
			}
			if vals[i] <= vals[i-1] {
				nonInc++
			}
		}
		monoPct := math.Max(float64(nonDec), float64(nonInc)) / float64(len(vals)-1) * 100

		// counter-likeness: fraction of steps that increase by 1-5 (small increments)
		counterSteps := 0
		for i := 1; i < len(vals); i++ {
			d := vals[i] - vals[i-1]
			if d > 0 && d <= 5 {
				counterSteps++
			}
		}
		counterPct := float64(counterSteps) / float64(len(vals)-1) * 100

		// correlation with volt, curr, t1
		corrV := pearson(vals, volt)
		corrC := pearson(vals, curr)
		corrT1 := pearson(vals, t1)

		// repeats-with-t3 check
		matchesT3 := 0
		for i := range byteVals {
			if uint16(byteVals[i]) == (t3[i]&0xFF) || uint16(byteVals[i]) == (t3[i]>>8) {
				matchesT3++
			}
		}
		t3Pct := float64(matchesT3) / float64(len(byteVals)) * 100

		fmt.Printf("byte %2d: range[%.0f,%.0f] uniq=%d mono=%.0f%% counter=%.0f%% corrV=%.2f corrC=%.2f corrT1=%.2f matchT3=%.0f%%\n",
			offset, minV, maxV, len(unique), monoPct, counterPct, corrV, corrC, corrT1, t3Pct)
	}
}

func pearson(a, b []float64) float64 {
	n := float64(len(a))
	if n == 0 {
		return 0
	}
	var sumA, sumB, sumAB, sumA2, sumB2 float64
	for i := range a {
		sumA += a[i]
		sumB += b[i]
		sumAB += a[i] * b[i]
		sumA2 += a[i] * a[i]
		sumB2 += b[i] * b[i]
	}
	num := n*sumAB - sumA*sumB
	den := math.Sqrt((n*sumA2 - sumA*sumA) * (n*sumB2 - sumB*sumB))
	if den == 0 {
		return 0
	}
	return num / den
}
