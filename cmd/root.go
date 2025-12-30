/*
Copyright © 2025 Valentyn Solomko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	cfgFile   string
	logLevel  string
	logFormat string
	version   = "0.1.0" // Version is set via ldflags during build
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:     "crawfaha",
	Version: version,
	Short:   "Crawler for projects from FreelanceHunt.",
	Long:    `Crawler for projects from FreelanceHunt using their REST API. It detects suitable projects and creates bets for them.`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	// Run: func(cmd *cobra.Command, args []string) { },
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		return setupLogging()
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	CheckErr(err, "Command execution failed")
}

func init() {
	cobra.OnInitialize(initConfig)

	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.crawfaha.yaml)")
	rootCmd.PersistentFlags().StringVar(&logLevel, "log-level", "info", "log level (debug, info, warn, error)")
	rootCmd.PersistentFlags().StringVar(&logFormat, "log-format", "json", "log format (json, text)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	// rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")

	// Bind flags to viper
	viper.BindPFlag("log.level", rootCmd.PersistentFlags().Lookup("log-level"))
	viper.BindPFlag("log.format", rootCmd.PersistentFlags().Lookup("log-format"))
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		// Find home directory.
		home, err := os.UserHomeDir()
		CheckErr(err, "Failed to get home directory")

		// Search config in home directory with name ".crawfaha" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigType("yaml")
		viper.SetConfigName(".crawfaha")

		// Look for config in the following locations:
		// 1. Current directory
		// 2. $HOME/.crawfaha
		// 3. /etc/crawfaha (for system-wide settings)
		viper.AddConfigPath(".")
		viper.AddConfigPath(filepath.Join(home, ".crawfaha"))
		viper.AddConfigPath("/etc/crawfaha")
		viper.SetConfigType("yaml")
		viper.SetConfigName("config")

	}

	// Read environment variables prefixed with CRAWFAHA_
	viper.SetEnvPrefix("CRAWFAHA")
	viper.AutomaticEnv() // read in environment variables that match

	// Set defaults
	setDefaults()

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		log.Debug().Str("config", viper.ConfigFileUsed()).Msg("Using config file")
	}
}

// setDefaults sets default configuration values
func setDefaults() {

	// Logging defaults
	viper.SetDefault("log.level", "info")
	viper.SetDefault("log.format", "json")
}

// setupLogging configures zerolog based on flags and config
func setupLogging() error {
	// Set log level
	level := viper.GetString("log.level")

	switch level {
	case "debug":
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	case "info":
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	case "warn":
		zerolog.SetGlobalLevel(zerolog.WarnLevel)
	case "error":
		zerolog.SetGlobalLevel(zerolog.ErrorLevel)
	default:
		return fmt.Errorf("invalid log level: %s", level)
	}

	// Set log format
	format := viper.GetString("log.format")
	if format == "text" {
		log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	}

	log.Debug().
		Str("level", level).
		Str("format", format).
		Msg("Logging initialized")

	return nil
}

func CheckErr(err error, msg string) {
	if err != nil {
		log.Error().Err(err).Msg(msg)
		os.Exit(1)
	}
}
