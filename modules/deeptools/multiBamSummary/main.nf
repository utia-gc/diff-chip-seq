process multi_bam_summary {
    // Process settings label
    label 'deepTools'

    // Resources labels
    label 'big_cpu'
    label 'big_mem'
    label 'def_time'

    input:
        tuple path(bams), path(bais)

    output:
        path 'coverage-matrix.npz', emit: coverageMatrix

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        multiBamSummary bins \\
            --numberOfProcessors ${task.cpus} \\
            --outFileName coverage-matrix.npz \\
            ${args} \\
            --bamfiles ${bams}
        """
}
