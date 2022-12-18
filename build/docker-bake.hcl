group "default" {
  targets = ["1_29_0"]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/armhf", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

target "1_29_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/unit-php:1.29", "docker.io/nlss/unit-php:1.29.0", "docker.io/nlss/unit-php:latest"]
  args = {
    UNIT_VERSION = "1.29.0"
  }
}
