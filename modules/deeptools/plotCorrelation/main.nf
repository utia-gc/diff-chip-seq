process plot_correlation {
    // Process settings label
    label 'deepTools'

    // Resources labels
    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    // Publish data
    publishDir(
        path:    "${params.publishDirReports}/.chip",
        mode:    "${params.publishMode}",
        pattern: "correlation*"
    )

    input:
        path coverageMatrix

    output:
        path 'correlation.png',      emit: correlationPlot
        path 'correlation-data.txt', emit: correlationData

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        plotCorrelation \\
            --plotFile correlation.png \\
            --outFileCorMatrix correlation-data.txt \\
            ${args} \\
            --corData ${coverageMatrix}
        """
}
