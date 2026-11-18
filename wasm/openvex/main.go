package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/rampart-aspm/parsers/pkg/domain"
)

func main() {
	p := NewParser()
	w := bufio.NewWriter(os.Stdout)
	defer w.Flush()

	enc := json.NewEncoder(w)
	ctx := context.Background()
	pc := domain.ParseContext{
		TenantID:      domain.NewID(),
		ScanSourceID:  domain.NewID(),
		ScannerFamily: "openvex",
		Track:         "main",
	}

	for f, err := range p.Parse(ctx, os.Stdin, pc) {
		if err != nil {
			fmt.Fprintf(os.Stderr, "openvex wasm parse error: %v\n", err)
			os.Exit(1)
		}
		if err := enc.Encode(f); err != nil {
			fmt.Fprintf(os.Stderr, "openvex wasm encode error: %v\n", err)
			os.Exit(1)
		}
	}
}
