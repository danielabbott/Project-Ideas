CC?=clang
SOURCES=glad.c gl.c
OBJECTS=$(SOURCES:.c=.o)
EXE = svgtest

CFLAGS=-c -std=gnu99 -Wall -Wextra -Og -g -Wpedantic -I. -fstack-protector-all `pkg-config --cflags glfw3`

LDFLAGS=-Og -g `pkg-config --libs glfw3` -ldl

all: $(EXE)

$(EXE): $(OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm $(OBJECTS)


