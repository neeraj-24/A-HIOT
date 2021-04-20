# A-HIOT
A-HIOT stands for an advanced virtual screening (VS) framework ˗ automated hit
identification and optimization tool (A-HIOT) that integrates machine learning (ML) and
deep neural networks (DNNs), and combines conventional approaches based on the
chemical space (AI-dependent predictive model derived from standard ligand information
for respective targets) and protein space (target structure information collection and AI-
dependent prognostic model extracted from the interaction pattern of target-ligand
complexes). A-HIOT bridges the long-standing gap between both types of methods (LBVS
and SBVS).

## Prerequisites
1. The following standalone packages and tools are required:
- PaDEL-Descriptor
- Open Babel – An open chemical toolbox
- Cavity
- Pocket v3
- AutoDock Tools
- AutoDock Vina
- Protein Ligand Interaction Profiler (PLIP)
- PyMOL
- R v3.6 or above
- H2o package in R for Artificial Intelligence 
 
2. The second requirement is selection of a specific or set of similar receptor structures belongs to the same family and well established/profiled inhibitors or modulators for respective protein.
 
## Steps
### Establishing chemical space
- **Features calculation and data preprocessing for training dataset.**

Collect all molecules and convert them into sdf format using Open Babel:

```
$ Sh mol_to_sdf.sh

And move all the sdf files into a single directory.

$ mkdir directioy_name (change 'directioy_name' as per convenience)
$ mv *.sdf directioy_name
 
```

Open PaDEL-Descriptor and select sdf molecules containing directory and calculate 1D and 2D descriptors. The descriptors.csv further requires preprocessing to overcome curse of dimensionality, apply following perl programs

```
$ perl removal_of_zeros.pl descriptors.csv > refined_zeros_descriptors.csv
$ perl sd_csv.pl refined_zeros_descriptors.csv > refined_zeros_and_sd_descriptors.csv

```
Calculate correlation between each descriptor employing R package corrplot as
```
$ R
Data <- read.csv(file=” refined_zeros_and_sd_descriptors.csv”, header=T) 
             require (corrplot)
	my_corr <- cor(data, method = “Pearson”, use = “complete.obs”)
	write.csv(my_corr, “/home/user/data_preprocessing/ refined_corr_descriptors.csv”,    row_names=TRUE)

```
The correlation containing file processed as the descriptors with more than 0.90 values are removed to maintain data consistency as

```
$ perl corr.pl  refined_corr_descriptors.csv > corr_processed.csv
```
The descriptor names are copied from corr_processed.csv file and used as input in "**ext_final.pl**" to extract final file as initial:
```
$ perl ext_final.pl descriptors.csv > Final_ML_ready_file.csv
```
Now label the molecules 1 (inhibtors) and 0 (non-inhibitor) in Final_ML_ready_file.csv and make it ready for machine learning.

- **Features calculation and data preprocessing for independent validation dataset**

Collect all molecules and convert them into sdf format using Open Babel.
Administer sdf files to PaDEL-Descriptor and calculate 1D and 2D features for independent validation dataset (ind_valid_set.csv). 
Edit "**ext_validation.pl**" by adding all features in "**Final_ML_ready_file.csv**" and extract validation file as:
```
$ perl removal_of_zeros.pl descriptors.csv > refined_zeros_descriptors.csv
$ perl sd_csv.pl refined_zeros_descriptors.csv > refined_zeros_and_sd_descriptors.csv
```
- **Machine learning (ML) models**

1. To train random forest (RF) model keep Final_ML_ready_file.csv file into a defined path and follow accordingly

```
$ R
Source(“RF_train.R”)
```
The automated RF_train script produce AUC-ROC plot and confusion matrices for train and test dataset and top 30 features.

To find true positives (Identified hits) for internal training
```
$ sh RF_prediction_training.sh
```
And it produces "**Identified_hits_for_internal_training.txt**"
 
Application of predictive model for independent validation dataset
```
Source (“RF_valid.R”)
$ sh RF_prediction_training.sh
```
And it produces "**Identified_hits_from_independent_set.txt**"

2. To train extreme gradient boost (XGB) model keep "**Final_ML_ready_file.csv**"  file into a defined path and follow accordingly
```
$ R
Source(“xgb_train.R”) 
```
The automated **xgb_train** script produce AUC-ROC plot and confusion matrices for train and test dataset and top 30 features.

Application of predictive model for independent validation dataset 
```
Source (xgb_valid.R”)
```
3. To train deep neural networks/deep learning (DNNs/DL) model keep.

"**Final_ML_ready_file.csv**" file into a defined path and follow accordingly
```
$ R
Source(“DL_train.R”)
```
The automated DL_train script produce AUC-ROC plot and confusion

matrices for train and test dataset and important features.

To find true positives (Identified hits) for internal training
```
$ sh DL_prediction_training.sh
```
And it produces "**Identified_hits_for_internal_training.txt**"

Application of predictive model for independent validation dataset

```
Source (“DL_valid.R”)
$ sh DL_prediction_training.sh
```
And it produces "**Identified_hits_from_independent_set.txt**"

- **Stacked ensemble model**

To train stacked ensemble model keep Final_ML_ready_file.csv file into a defined path and follow accordingly
```
$ R
Source(“ensemble_train.R”) 
```
The automated ensemble_train script produces AUC-ROC plot and confusion matrices for train and test dataset along with performance of each base-learner and super-learner algorithms. 
To find true positives (Identified hits) for internal training

```
$ sh ENS_prediction_training.sh

```
And it produces "**Identified_hits_for_internal_training.txt**".
Application of predictive model for independent validation dataset 

```
Source (“ensemble_valid.R”)
$ sh ENS_prediction_training.sh

```
And it produces "**Identified_hits_from_independent_set.txt**"
The identified hits further used as input for protein space phase.

### Establishing protein space

- **Molecular docking and complex generation**

1. Collect and place all true positives, true negatives retrieved from stacked ensemble step and protein structure in common directory.
2. Prepare protein and ligand molecules for docking simulation using AutoDock Tools as per (Forli, S., Huey, R., Pique, M. et al. Computational protein–ligand docking and virtual drug screening with the AutoDock suite. Nat Protoc 11, 905–919 (2016). https://doi.org/10.1038/nprot.2016.051 )
3. Keep grid box configuration file, prepared ligand molecules and protein in same direction and set up automated protein-ligand docking using following shell script
```
$ sh vina_screening.sh
```
Autodock vina produce docked ligand along with nine conformations within binding pocket.
4. Extract first conformation that has been docked within receptor protein and move it into new directory named as per molecules name using given shell script
```
$sh output_pdbqt_to_pdb.sh 
copy protein structure to each directory using
$sh copy_receptor_str_to_each_directory.sh
```
and generate complex for next analytic step using following shell script
```
$ sh complex.sh
# move complex files to two different directories (Dir_complex_1 and Dir_complex_2) employing following shell script
$ sh copying_complex_to_common_directory.sh
```
5. Go to Dir_complex_1 convert complex.pdb files into SMILES (smi) format employing shell script
```
$sh pdb_to_smi.sh 
Copy SMILES files to a common directory (smiles_complex) and calculate Klekota-Roth binary fingerprint counts employing PaDEL and save fingerprint file into DL_klekota.csv.
```
- **Deep neural network (DNNs/DL) for fingerprint based predictive model**

To train DNNs/DL model keep DL_klekota.csv file into Dir_complex_1 and follow accordingly
```
$ R
Source(“training_DL_klekota.R”) 
The automated training_DL_klekota.R script produces AUC-ROC plot and confusion matrices for train and test dataset.
To find true positives (Identified hits) for internal training
$ sh DL_FP_prediction_training.sh
And it produces Optimized_hits_for_internal_training.txt
Application of predictive model for independent validation dataset 
Source (“validation_DL_klekota.R”)
$ sh DL_FP_prediction_training.sh
And it produces Optimized _hits_from_independent_set.txt
```
- **Protein-ligand interaction profiling**
1. Go to plip-master directory and execute following shell script editing one directories path containing complex files, and it will generate Protein-ligand interaction profiles for each protein ligand complex
```
$ sh plip_generation_running.sh 
The shell script would generate different directory for each complex file.
```
2. Move or copy PLIP report files into a common directory (Dir_complex_2/report_inter_complex) and rename report file for easy understanding  employing following shell script
```
$ sh copying_report_file_to_common_folder.sh
$ sh renaming_report_file.sh
```
3. To collect total number of interaction and convert them into table employing following shell script, the script executed within report_inter_complex directory
```
$ sh interaction_table.sh
The interaction types and total numbers stored in TABLR_RESNR
```
- **Final selection of optimized hits**
```
Copy TABLR_RESNR to Dir_complex_1 and to select final optimized hits employ following shell script
$ sh final_selection_of_optimized_hits.sh
```






