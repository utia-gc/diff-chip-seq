process plot_pca {
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
        pattern: "pca*"
    )

    input:
        path coverageMatrix

    output:
        path 'pca.png',      emit: pcaPlot
        path 'pca-data.txt', emit: pcaData

    script:
        String args = new Args(task.ext).buildArgsString()

        """
        plotPCA \\
            --plotFile pca.png \\
            --outFileNameData pca-data.txt \\
            ${args} \\
            --corData ${coverageMatrix}
        """
}
