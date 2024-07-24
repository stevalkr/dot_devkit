BUILD_DIR := $(HOME)/.devkit/builds/{{ project_name }}

all: $(BUILD_DIR)
	sk build -y -- -j

$(BUILD_DIR):
	sk build -y -- -DCMAKE_COLOR_DIAGNOSTICS=OFF

clean:
	sk clean -y

