include { khmer_unique_kmers } from '../modules/khmer/unique_kmers'


workflow CALL_PEAKS {
    take:
        genome

    main:
        // compute effective genome size
        khmer_unique_kmers(genome)
}
