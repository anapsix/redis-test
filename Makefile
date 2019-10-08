UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  OS:= darwin
  GREP:= ggrep
endif
ifeq ($(UNAME_S),Linux)
  OS:= linux
  GREP:= grep
endif
UNAME_M:= $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
  ARCH:= amd64
endif

CLI:= redis-test

VERSION:= $(shell $(GREP) -Po '(?<=^version: ).*' shard.yml)
TARGET:= src/$(CLI)
RELEASE_DIR:= bin
OUTPUT:= $(RELEASE_DIR)/$(CLI)-$(VERSION)-$(OS)-$(ARCH)

.PHONY: all clean version

all: clean releases

releases: version $(TARGET) pack docker
	docker run -it --rm -v ${PWD}/${RELEASE_DIR}:/app --entrypoint "sh" $(CLI):$(VERSION) -c "cp /$(CLI) /app/$(CLI)-$(VERSION)-linux-amd64"

docker:
	docker build -t $(CLI):$(VERSION) .
	docker tag $(CLI):$(VERSION) $(CLI):latest

clean:
	@rm -f $(RELEASE_DIR)/*
	@echo >&2 "cleaned up"

version:
	@echo "Version set to $(VERSION)"

$(TARGET): % : $(filter-out $(TEMPS), $(OBJ)) %.cr
	@crystal build src/$(CLI).cr -o $(OUTPUT) --progress
	@echo "compiled binaries places to \"./$(RELEASE_DIR)\" directory"

pack:
	@find $(RELEASE_DIR) -type f -name "$(CLI)-$(VERSION)-$(OS)-$(ARCH)" | xargs upx
