.PHONY: docker-generate 
# Docker image for buf
BUF_IMAGE := bufbuild/buf:1.64

# Generate code from proto files
docker-generate:
	@echo "Generating code from proto files..."
	@mkdir -p .buf/cache
	docker run --rm \
		-v $$(pwd):/workspace \
		-v $$(pwd)/.buf/cache:/root/.cache/buf \
		-w /workspace \
		--entrypoint sh \
		$(BUF_IMAGE) \
		-c "buf dep update && buf lint && buf generate "

buf-install:
	brew install bufbuild/buf/buf

buf-gen:
	$(MAKE) buf-dep && $(MAKE) buf-lint && $(MAKE) buf-generate 

buf-lint:
	buf lint

buf-dep:
	buf dep update

buf-generate:
	buf generate
	
buf-generate-js:
	buf generate --template js.gen.yaml --include-imports && cd ts  && sh generate-index.sh && cd -
	

buf-download:
	buf export buf.build/googleapis/googleapis -o third_party

git-submodule-sync:
	git submodule update --init --recursive