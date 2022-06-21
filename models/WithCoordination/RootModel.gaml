/**
* Name: RootModel
* Based on the internal empty template. 
* Author: DINAHARISONBienvenue
* Tags: 
*/


model RootModel

import 'MicroOrganismModel.gaml'
import 'SoilModel.gaml'
/* Insert your model definition here */

species root parent:modele {
	
	float income;
	
	reflex act when:is_allowed_to_run{
		do eat;
		do get_gain;
	}
	
	action eat {
		do request_modification parameter:"soluble_MM" value:-racine_SMM;
	}
	
	action get_gain{
		float gain;
		ask particle{
			 gain <- self.get_income(myself,"soluble_MM");			
			 myself.income <- myself.income + gain;
		}
	}
	
	aspect base{
		draw circle(0.5) color:#purple;
	}
}