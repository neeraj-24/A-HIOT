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
- Features calculation and data preprocessing for training dataset.

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


