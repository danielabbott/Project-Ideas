#include <assert.h>
#include <glad/glad.h>
#include <stdio.h>
#include <stdlib.h>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <stdbool.h>

GLFWwindow * window;

GLint window_dimensions_uniform_handle;
GLuint vao;

void create_window();
void load_shaders();
void create_gl_state();
void render();
void window_loop();
void cleanup();

void check(bool x) {
	if(!x) {
		assert(false);
		exit(1);
	}
}

int main()
{
	create_window();
	load_shaders();
	create_gl_state();
	render();
	window_loop();
	cleanup();
	return 0;
}

void create_window()
{
	check(glfwInit());

	glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_STENCIL_BITS, 0);
	glfwWindowHint(GLFW_DEPTH_BITS, 0);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE);
	glfwWindowHint(GLFW_SAMPLES, 0);
	// glfwWindowHint(GLFW_SRGB_CAPABLE, GLFW_TRUE);

	window = glfwCreateWindow(800, 600, "SVG Test", NULL, NULL);
	check (window);

	glfwMakeContextCurrent(window);
	check(gladLoadGLLoader((GLADloadproc)glfwGetProcAddress));
	glfwSwapInterval(0);

}

void load_shaders()
{
	GLuint vsid, fsid;

	{
		FILE * f = fopen("vs.glsl", "r");
		check(f);

		fseek(f, 0, SEEK_END);
		long sz = ftell(f);
		check(sz > 0);
		fseek(f, 0, SEEK_SET);

		char * data = malloc(sz+1);
		check(data);
		fread(data, sz, 1, f);
		data[sz] = 0;
		fclose(f);

		vsid = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vsid, 1, (const char **)&data, NULL);
		glCompileShader(vsid);
		free(data);

		GLint status;
		glGetShaderiv(vsid, GL_COMPILE_STATUS, &status);
		if (status == GL_FALSE) {
			printf("Error compiling vertex shader\n");

			GLint logSize = 0;
			glGetShaderiv(vsid, GL_INFO_LOG_LENGTH, &logSize);

			if (logSize > 0) {
				char * log = malloc(logSize + 1);
				glGetShaderInfoLog(vsid, logSize, NULL, log);
				log[logSize] = 0;

				printf("%s\n", log);
			}

			check(false);
		}
	}

	{
		FILE * f = fopen("fs.glsl", "r");
		check(f);

		fseek(f, 0, SEEK_END);
		long sz = ftell(f);
		check(sz > 0);
		fseek(f, 0, SEEK_SET);

		char * data = malloc(sz+1);
		check(data);
		fread(data, sz, 1, f);
		data[sz] = 0;
		fclose(f);

		fsid = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fsid, 1, (const char **)&data, NULL);
		glCompileShader(fsid);
		free(data);

		GLint status;
		glGetShaderiv(fsid, GL_COMPILE_STATUS, &status);
		if (status == GL_FALSE) {
			printf("Error compiling fragment shader\n");

			GLint logSize = 0;
			glGetShaderiv(fsid, GL_INFO_LOG_LENGTH, &logSize);

			if (logSize > 0) {
				char * log = malloc(logSize + 1);
				glGetShaderInfoLog(fsid, logSize, NULL, log);
				log[logSize] = 0;

				printf("%s\n", log);
			}

			check(false);
		}
	}

	GLuint id = glCreateProgram();
	check(id);

	glAttachShader(id, vsid);
	glAttachShader(id, fsid);

	glBindAttribLocation(id, 0, "in_position");

	glLinkProgram(id);

	GLint status;
	glGetProgramiv(id, GL_LINK_STATUS, &status);
	if (status == GL_FALSE) {
		printf("Error linking shaders\n");

		GLint logSize = 0;
		glGetProgramiv(id, GL_INFO_LOG_LENGTH, &logSize);

		if (logSize) {
			char * log = malloc(logSize + 1);
			glGetProgramInfoLog(id, logSize, NULL, log);
			log[logSize] = 0;

			printf("%s\n", log);
		}


		check(false);
	}

	glUseProgram(id);


	window_dimensions_uniform_handle = glGetUniformLocation(id, "windowDimensions");
	check(window_dimensions_uniform_handle != -1);

}


void create_gl_state()
{
	glDisable(GL_MULTISAMPLE);
	glDisable(GL_BLEND);
	glDisable(GL_CULL_FACE);
	// glEnable(GL_FRAMEBUFFER_SRGB);

	glUniform2f(window_dimensions_uniform_handle, 800, 600);

	glGenVertexArrays(1, &vao);
	check(vao);

	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);


	check(!glGetError());
}

void render()
{
	glDrawArrays(GL_TRIANGLES, 0, 3);

	check(!glGetError());


	glfwSwapBuffers(window);
}

void window_loop()
{
    while(!glfwWindowShouldClose(window) && !glfwGetKey(window, GLFW_KEY_ESCAPE)) {
        render();
        glfwWaitEvents();
    }
}

void cleanup()
{
	glfwDestroyWindow(window);
	glfwTerminate();
}

