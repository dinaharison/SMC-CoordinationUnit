/**
* Name: MicroOrganismModel
* Based on the internal empty template. 
* Author: DINAHARISONBienvenue
* Tags: 
*/


model MicroOrganismModel

import 'SoilModel.gaml'

/* Insert your model definition here */

species modele skills:[coupled_model]{
	space particle;
	
	init{ 
		do set_space_particle space:particle;
		self.location <- any_location_in(particle);
	}
	
	float growth(float res, float r, float K){
		return (r * res * (1-(res/K)));
	}
	
	space relocate_to(space sub_space){
		location <- any_location_in(sub_space);
		return sub_space;
	}
}