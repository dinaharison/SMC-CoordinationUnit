/**
* Name: MatterConsumptionModel
* Based on the internal empty template. 
* Author: DINAHARISONBienvenue
* Tags: 
*/


model SimpleMatterConsumptionModel

/* Insert your model definition here */
import 'SoilModel.gaml'
import 'MicrobeModel.gaml'
import 'WormModel.gaml'
import 'RootModel.gaml'

global skills:[scheduleV2] {
	int soil_height <- 10;
	int soil_width <-10;
	
	float C_scarce_thsd <- 3.0;
	float C_min <- 1.0;
	float C_max <- 40.0;
	
	float raw_OM_decomp_rate<- 1.3;
	float decomposed_OM_consumption_rate <- 0.03;
	float soluble_OM_consumption_rate <- 0.007;
	float racine_SOM <- 0.006;
	float disolve_SOM <- 0.005;
	float racine_SMM <- 0.008;
	float microbe_SMM <- 0.009;
	
	float step_global <- 2#days;
	float step_microbe <- 4#hours;
	float step_root <- 12#hours;
	float step_worm <- 1#days;
	
	float pop_init <- 1000.0;
	float r_copio <- 1.2;
	float r_oligo <- 1.0;
	float K_copio <- 1000.0;
	float K_oligo <- 50.0;
	
	int worm_nb<-1;
	int microbe_nb <- 5;
	int root_nb <- 2;
	
	list<space> PORE;
	list<space> ORGANIC;
	
	string my_file <- "../../includes/results.csv";
	file soil_data <- csv_file("../../includes/soildata.csv",",");
	
	init {
		
		step <- step_global;
		
		ask space{
			matrix data <- matrix(soil_data);
			int value <- int(data[grid_x,grid_y]);
			switch(value){
				match 1 {my_type<-"organic";}
				match 2 {my_type<-"mineral";}
				default {my_type<-"pore";}
			}
		
			color <- selectColor();
			
			raw_OM <- my_type="organic"? C_max:0.0;
			
			if(my_type = "pore"){
				create microbe number:5 with:(particle:self);
				create worm number:1 with:(particle:self);
				create root number:2 with:(particle:self);
			}
		}
		
		do count_particles;
		
		do scheduler_insert process:microbe step:step_microbe;
		do scheduler_insert process:root step:step_root;
		do scheduler_insert process:worm step:step_worm;
	}
	
	
	action count_particles{
		PORE <- space where(each.my_type="pore");
		ORGANIC <- space where(each.my_type="organic");
	}
	
	action place_microbe(space pp){
		create microbe number:microbe_nb with:(particle:pp);
	}
	
	reflex r_scheduler{
		do schedule;
	}
	
	reflex record{
			
			float rOM <- sum_of(space, each.raw_OM);
			float dOM <- sum_of(space, each.decomp_OM);
			float sOM <- sum_of(space, each.soluble_OM);
			
			save [ cycle, rOM, dOM, sOM] to: my_file type: "csv" rewrite:false;
	}
	reflex pauser when:(cycle = 60){
		do pause;
	}
}

experiment WithoutCoordinationFunction type: gui {
	
	parameter "soil height" var:soil_height min:1 max:20 category:"Environment";
	parameter "soil width" var:soil_width min:1 max:20 category:"Environment";

	parameter "OM scarce Threshold" var:C_scarce_thsd category:"Environment";
	parameter "Minimal raw OM" var:C_min min:0.1 max:10.0 category:"Environment";
	parameter "Maximum raw OM" var:C_max min:10.0 max:100.0 category:"Environment";
	
	
	parameter "Raw OM decomposition" var:raw_OM_decomp_rate category:"Worm";
	parameter "Step worm" var:step_worm category:"Worm" unit:#day;
	parameter "Number worm" var:worm_nb category:"Worm";
	
	parameter "Decomposed OM consumption" var:decomposed_OM_consumption_rate category:"Microbe";
	parameter "Soluble OM Consumption/colony" var:soluble_OM_consumption_rate category:"Microbe";
	parameter "Disolution on Soluble OM" var:microbe_SMM category:"Microbe";
	parameter "Step microbe" var:step_microbe category:"Microbe" unit:#hours;
	parameter "Number microbe" var:microbe_nb category:"Microbe";
	
	parameter "Soluble MM Consumption/root" var:racine_SMM category:"Roots";
	parameter "Step roots" var:step_root category:"Roots" unit:#hours;
	parameter "Number roots" var:root_nb category:"Roots";
	
	output {
		
//		monitor "Decomposed OM" value: sum_of(space, each.decomp_OM) refresh:every(1#day);
//		monitor "Raw OM" value: sum_of(space, each.raw_OM) refresh:every(1#day);
//		monitor "Soluble OM" value:sum_of(space, each.soluble_OM) refresh:every(1#day);
//		monitor "Soluble MM" value:sum_of(space, each.soluble_MM) refresh:every(1#day);
//		
//		monitor "Microbe Colony" value: length(microbe) refresh:every(1#day);
//		monitor "Active Microbe Colony" value: length(microbe where(each.active=true)) refresh:every(1#day);
//		monitor "Nb of Pore" value: length(space where(each.my_type="pore")) refresh:every(1#day);
//		monitor "Nb of Organic" value: length(space where(each.my_type="organic")) refresh:every(1#day);
//		monitor "Nb of Mineral" value: length(space where(each.my_type="mineral")) refresh:every(1#day);
//		
		/*display soil {
			grid space lines:#black;
			species microbe aspect:base;
			species worm aspect:base;
			species root aspect:base;
		}*/
		
		display ressource_chart refresh:every(1#day){
			chart "Ressources Over Time" type:series x_label:"Days" y_label:"Ressource Amount"{
				data "RAW OM" value:sum_of(space, each.raw_OM) color:#red;
				data "DECOMPSED OM" value:sum_of(space, each.decomp_OM) color:#blue;
				data "SOLUBLE OM" value:sum_of(space, each.soluble_OM) color:#green;
				data "SOLUBLE MM" value:sum_of(space,each.soluble_MM) color:#black;
				data "NB CONFLICT" value:sum_of(space,each.nb_conflict)*10 color:#darkviolet;
			} 
		}
		
		display soil {
			grid space lines:#black;
		}
	}
}