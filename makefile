target:
	
	-rm -rf newton_fractal_generator_build
	
	mkdir newton_fractal_generator_build
	cd newton_fractal_generator_build; \
	cmake ../src; \
	make
	
	
	
	./newton_fractal_generator_build/Newton_fractal_generator
