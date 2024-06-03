package main

import (
	"log"

	"github.com/GreekKeepers/golangBackend/config"
	"github.com/GreekKeepers/golangBackend/internal/app"
)

func main() {
	cfg, err := config.New()
	if err != nil {
		log.Panic(err)
	}

	app.Run(cfg)
}
