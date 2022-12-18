group "default" {
  targets = ["1_29_0_PHP81", "1_29_0_PHP82"]
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

target "1_29_0_PHP81" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/unit-php:1.29-PHP8.1", "docker.io/nlss/unit-php:1.29.0-PHP8.1"]
  args = {
    UNIT_VERSION = "1.29.0"
    PHP_VERSION = "8.1"
  }
}

target "1_29_0_PHP82" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/unit-php:1.29-PHP8.2", "docker.io/nlss/unit-php:1.29.0-PHP8.2", "docker.io/nlss/unit-php:latest"]
  args = {
    UNIT_VERSION = "1.29.0"
    PHP_VERSION = "8.2"
  }
}
