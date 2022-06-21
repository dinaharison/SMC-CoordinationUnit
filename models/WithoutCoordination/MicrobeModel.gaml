/**
* Name: MicrobeModel
* Based on the internal empty template. 
* Author: DINAHARISONBienvenue
* Tags: 
*/


model MicrobeModel

/* Insert your model definition here */

import 'MicroOrganismModel.gaml'
import 'SoilModel.gaml'

species microbe parent:modele {
	string my_type;
	float population;
	bool active <- false;
	rgb my_color;
	
	float decomp_rate;
	float feed_rate;
	
	float income;
	
	float r;
	float K;
	
	init{		
		decomp_rate <- decomposed_OM_consumption_rate;
		
		switch my_type{
			match "oligotrophe" {add self to:particle.oligo;}
			match "copiotrophe" {add self to:particle.copio;}
		}
		
		population <-rnd(pop_init);
		
		do switch_strategy;
		
		do activate;
		
		do particle_microbe_count;
		
	}
	
	reflex act when:is_allowed_to_run and active{
		if(particle.decomp_OM>=decomp_rate){
			do decompose;
		}
		do feed;
		do feedMM;
		do switch_strategy;
		
	}
	
	action activate {
		if(particle.my_type = "pore"){
			active <- true;
			my_color <- my_type="oligotrophe"?#red:#orange;
		}else{
			active <-false;
			my_color <- #transparent;
		}
	}
		
	action particle_microbe_count{
		ask particle{
			do count_micro_pop;
		}
	}
	
	action switch_strategy{
		my_type <- particle.soluble_OM<soluble_OM_consumption_rate?"oligothrophe":"copiotrophe";
		population <- my_type="oligothrophe"?population/100:population;
		r <- my_type="oligothrophe"? r_oligo:r_copio;
		K <- my_type="oligothrophe"? K_oligo:K_copio;
		color <- my_type="oligotrophe"?#red:#orange;
	}
	
	action gowth{
		population <- growth(self.population,r,K);
		do particle_microbe_count;
	}
	
	action feed{
		do request_modification parameter:"soluble_OM" value:-soluble_OM_consumption_rate;
		
		float gain;
		ask particle{
			gain <- self.get_income(myself, "soluble_OM");
			self.soluble_MM <- self.soluble_MM + (gain * (2/3));
		}
	}
	
	action feedMM{
		do request_modification parameter:"soluble_MM" value:-microbe_SMM;
		float gain;
		ask particle{
			gain <- self.get_income(myself, "soluble_MM");
			myself.income <- myself.income + gain;
		}
	}
	
	action decompose{
		do request_modification parameter:"decomp_OM" value:-decomposed_OM_consumption_rate;
		
		float outcome;
		ask particle{
			 outcome <- self.get_income(myself,"decomp_OM");			
			 self.soluble_OM <- self.soluble_OM + outcome;
		}
	}
	
	float respirate(float c_income){
		return c_income;
	}
	
	aspect base{
		
		draw circle(0.5) color:my_color;
		
	}
}