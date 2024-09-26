BUILD_DIR := $(shell sk build find_path)

all: $(BUILD_DIR)
	sk build -y -- -j

$(BUILD_DIR):
	sk build -y -- -DCMAKE_COLOR_DIAGNOSTICS=OFF

test:
	sk test -y

clean:
	sk clean -y



