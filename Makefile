.PHONY: install run test clean clean-all FORCE

PORT ?= 8080
LOWRES_FACTOR ?= 3
DATA ?= data/volume.nii.gz
LOWRES := $(patsubst %.nii.gz,%,$(DATA))_lowres.nii.gz
LOWRES_FACTOR_MARKER := $(dir $(DATA)).lowres_factor

install:
	npm install

FORCE:

# Gives a helpful error instead of make's generic "No rule to make target"
# when the expected volume is missing.
$(DATA):
	@echo "error: no NIfTI volume found at $(DATA)" >&2
	@echo "  Save your file there, or point at a different one: make run DATA=path/to/your.nii.gz" >&2
	@exit 1

# Rewritten only when LOWRES_FACTOR actually changes, so it can drive a rebuild of
# $(LOWRES) without forcing one on every `make run`.
$(LOWRES_FACTOR_MARKER): FORCE
	@if [ ! -f $(LOWRES_FACTOR_MARKER) ] || [ "$$(cat $(LOWRES_FACTOR_MARKER))" != "$(LOWRES_FACTOR)" ]; then \
		echo $(LOWRES_FACTOR) > $(LOWRES_FACTOR_MARKER); \
	fi

# Downsampled volume used for smooth live threshold-slider previews (see view.html).
# LOWRES_FACTOR is the per-axis decimation step (voxel count shrinks by FACTOR^3),
# e.g. `make run LOWRES_FACTOR=4`.
$(LOWRES): $(DATA) scripts/make_lowres.py $(LOWRES_FACTOR_MARKER)
	uv run --with nibabel python scripts/make_lowres.py $(DATA) $(LOWRES) $(LOWRES_FACTOR)

run: $(LOWRES)
	@echo "Open http://127.0.0.1:$(PORT)/view.html?data=$(DATA)"
	npx http-server -p $(PORT) -a 127.0.0.1 -c-1

test:
	@echo "No test suite"

clean:
	rm -rf __pycache__

clean-all: clean
	rm -rf node_modules $(LOWRES) $(LOWRES_FACTOR_MARKER)
