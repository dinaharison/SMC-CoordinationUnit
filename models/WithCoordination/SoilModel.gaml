/**
* Name: SoilModel
* Based on the internal empty template. 
* Author: DINAHARISONBienvenue
* Tags: 
*/


model SoilModel

import 'MicrobeModel.gaml'
import 'WormModel.gaml'
import 'RootModel.gaml'
import 'SimpleMatterConsumptionModel.gaml'

/* Insert your model definition here */

grid space height:soil_height width:soil_width neighbors:8 skills:[conflict_resolverV2]{
	
	string my_type;//pore,organic,mineral
	float soluble_OM;
	float decomp_OM;
	float raw_OM;
	float soluble_MM;
		
	list<microbe> copio;
	list<microbe> oligo;
	
	list<microbe> microbes;
	
	list<worm> worm_list;
	
	float copio_pop ;
	float oligo_pop ;
	
	int nb_conflict;
	
	
	init{
		nb_conflict <- 0;
		do define_coordinator_function parameter:"raw_OM" filter_using_model_attribute:"priority";
		do define_coordinator_function parameter:"soluble_OM" fair_distribution:true;
		do define_coordinator_function parameter:"decomp_OM" fair_distribution:true;
		do define_coordinator_function parameter:"soluble_MM" interspecific_competition:true dominant_species:root;
		
		do count_micro_pop;
	}
	
	action become_pore{
		if(my_type="organic" and raw_OM<raw_OM_decomp_rate){
			my_type <- "pore";
			color <- #white;
			ask world{
				do count_particles;
				do place_microbe pp:myself;
			}
			do count_micro_pop;
		}
	}
	
	action count_micro_pop{
		copio_pop <- copio sum_of(each.population);
		oligo_pop <- oligo sum_of(each.population);
		microbes <- microbe where(each.particle = self);
	}
	
	
	action define_worm_priority{
		int i <- 1;
		loop a_worm over: worm_list{
			ask a_worm {
				self.priority <- i;
				i <- i+1;
			}
		}	
	}
	
	rgb selectColor
	{
		switch(my_type)
		{
			match "pore" { return #white;}
			match "mineral" { return #black;}
			match "organic" { return #green;}
			default { return #blue;}
		}
	}	
}