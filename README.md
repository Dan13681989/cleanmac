# CleanMac - macOS Cleanup and Automation Scripts

A comprehensive collection of scripts for macOS maintenance, cleanup, and Docker management.

## Features
- System cleanup and optimization
- Docker network reset functionality
- Automated maintenance scripts

## Installation
```bash
git clone https://github.com/Dan13681989/cleanmac.git
cd cleanmac
chmod +x scripts/*/*.sh
```

## Usage

### Docker Network Reset
```bash
./scripts/docker/reset-docker-network.sh
```

### System Cleanup
```bash
./scripts/cleanup/system-cleanup.sh
```

## Project Structure

cleanmac/
├── scripts/
│   ├── docker/
│   │   └── reset-docker-network.sh
│   └── cleanup/
│       └── system-cleanup.sh
├── README.md
└── LICENSE

## License
MIT License - see LICENSE file for details.
