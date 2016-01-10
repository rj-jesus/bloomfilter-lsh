Bloom-filter + LSH
========================

Overview
--------

Bloom-Filter + LSH is a project which implements and uses both a Bloom filter and the Locality sensitive hashing technique. It was developed while we were taking "MPEI - Métodos Probabilísticos para Engenharia Informática".

It implements a two-stage email filter: first the emails are checked against a blacklist; if an email passes this stage its contents are compared against the knowladge the system has of other emails intended to be filtered. It thus initially requires a learning stage.  
The first stage uses a Bloom-filter, while the second one is based on LSH.

Special Notes
-------------

Our current in use hash function ([Farmhash](https://github.com/google/farmhash)) is interfaced with a MEX function, thus it needs to be compiled:

```mex Farmhash.cpp```

Pedro Martins  
Ricardo Jesus
