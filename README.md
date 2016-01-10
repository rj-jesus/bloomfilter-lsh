Bloom-filter + LSH
========================

Overview
--------

Bloom-Filter + LSH is a project which implements and uses both a Bloom filter and the Locality sensitive hashing technique. It was developed while we were taking "MPEI - Métodos Probabilísticos para Engenharia Informática".

Special Notes
-------------

Our current in use hash function ([Farmhash](https://github.com/google/farmhash)) is interfaced with a MEX function, thus it needs to be compiled:

```mex Farmhash.cpp```

Pedro Martins  
Ricardo Jesus
