/**
* Name: WormModel
* Based on the internal empty template. 
* Author: DINAHARISONBienvenue
* Tags: 
*/


model WormModel

import 'MicroOrganismModel.gaml'
import 'SoilModel.gaml'
/* Insert your model definition here */

species worm  parent:modele {
	
	list<space> available_organic;
	list<space> available_pore;
	
	int priority;
	
	space last_particle;
	float income;
	float total_income<-0.0;
	
	init{
		do get_available_organic;
		do get_available_pore;
	}
	
	reflex act when:is_allowed_to_run{
		switch(particle.my_type){
			match "pore" {
				do move;
				income <- 0.0;
			}
			match "organic" {do eat;do deject;}
		}		
	}
	
	action move{
		do get_available_organic;
		do get_available_pore;
		
		if(length(available_organic)=0){
			particle <- relocate_to(one_of(available_pore));
			do set_space_particle space:particle;
		}
		else if(length(available_organic)!=0){
			last_particle <- particle;
			space target <- one_of (available_organic);
			particle <- relocate_to(target);
			do set_space_particle space:particle;
		}
	}
	
	action eat{
			if(particle.raw_OM>raw_OM_decomp_rate){				
				do request_modification parameter:"raw_OM" value:-raw_OM_decomp_rate;
			}else{
				ask particle{
					do become_pore;
				}
			}
	}
	
	action deject{
		
		float outcome;
		
		ask particle {
			outcome <- self.get_income(myself,"raw_OM");
		}
		
		write "outcome " + outcome;
		
		ask last_particle{
			self.decomp_OM <- self.decomp_OM + outcome;
		}
	}
	
	action get_available_organic{
		available_organic <- particle.neighbors where (each.my_type="organic");
	}
	
	action get_available_pore {
		available_pore <- particle.neighbors where (each.my_type = "pore");
	}
	
	aspect base{
		draw rectangle({1,2}) color:#purple;
	}
}