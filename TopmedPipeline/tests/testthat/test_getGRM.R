context("getGRM tests")
library(GENESIS)
library(SeqArray)
library(SNPRelate)
library(Matrix)

.testConfig <- function(type) {
    gdsfmt::showfile.gds(closeall=TRUE, verbose=FALSE)
    config <- character()
    if (type == "pcrelate") {
        gds <- seqOpen(seqExampleFileName())
        grm <- pcrelate(SeqVarTools::SeqVarData(gds), freq.type="population", verbose=FALSE)
        seqClose(gds)
        grmfile <- tempfile()
        save(grm, file=grmfile)
        config["pcrelate_file"] <- grmfile
    } else if (type == "pcrelate_gds") {
        config["pcrelate_file"] <- system.file("extdata", "HapMap_ASW_MXL_pcrelate.gds", package="GENESIS")
    } else if (type == "grm") {
        gds <- seqOpen(seqExampleFileName())
        grm <- snpgdsGRM(gds, verbose=FALSE)
        seqClose(gds)
        grmfile <- tempfile()
        save(grm, file=grmfile)
        config["grm_file"] <- grmfile
    } else if (type == "grm_gds") {
        gds <- seqOpen(seqExampleFileName())
        grmfile <- file.path(tempdir(), "tmp.gds")
        grm <- snpgdsGRM(gds, out.fn=grmfile, verbose=FALSE)
        seqClose(gds)
        config["grm_file"] <- grmfile
    } else if (type == "grm_Matrix") {
        gds <- seqOpen(seqExampleFileName())
        grm <- snpgdsGRM(gds, verbose=FALSE)
        seqClose(gds)
        grm <- Matrix(grm$grm, dimnames=list(grm$sample.id, grm$sample.id))
        grmfile <- tempfile()
        save(grm, file=grmfile)
        config["grm_file"] <- grmfile
    } else if (type == "king") {
        gds <- seqOpen(seqExampleFileName())
        grm <- snpgdsIBDKING(gds, verbose=FALSE)
        seqClose(gds)
        grmfile <- tempfile()
        save(grm, file=grmfile)
        config["king_file"] <- grmfile
    } else if (type == "king_gds") {
        gds <- seqOpen(seqExampleFileName())
        grm <- snpgdsIBDKING(gds, verbose=FALSE)
        seqClose(gds)
        grmfile <- file.path(tempdir(), "tmp.gds")
        list2gds(grm, grmfile)
        config["king_file"] <- grmfile
    }
    config
}

.cleanupConfig <- function(config) {
    unlink(config[c("grm_file")])
}

test_that("pcrelate", {
    config <- .testConfig(type="pcrelate")
    pcr <- getobj(config["pcrelate_file"])
    samp <- pcr$sample.id[1:10]
    grm <- getGRM(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "matrix")
    expect_equal(colnames(grm), samp)
})

test_that("pcrelate_gds", {
    config <- .testConfig(type="pcrelate_gds")
    pcr <- openfn.gds(config["pcrelate_file"])
    samp <- as.character(read.gdsn(index.gdsn(pcr, "sample.id"))[1:10])
    closefn.gds(pcr)
    grm <- getGRM(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "matrix")
    expect_equal(colnames(grm), samp)
})

test_that("grm", {
    config <- .testConfig(type="grm")
    
    x <- getobj(config["grm_file"])
    samp <- x$sample.id[1:10]
    grm <- getGRM(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "matrix")
    expect_equal(colnames(grm), samp)
    
    .cleanupConfig(config)
})

test_that("grm_gds", {
    config <- .testConfig(type="grm_gds")
    
    x <- openfn.gds(config["grm_file"])
    samp <- read.gdsn(index.gdsn(x, "sample.id"))[1:10]
    closefn.gds(x)
    grm <- getGRM(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "matrix")
    expect_equal(colnames(grm), samp)
    
    .cleanupConfig(config)
})

test_that("grm_Matrix", {
    config <- .testConfig(type="grm_Matrix")
    
    x <- getobj(config["grm_file"])
    samp <- rownames(x)[1:10]
    grm <- getGRM(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "Matrix")
    expect_equal(colnames(grm), samp)
    
    .cleanupConfig(config)
})

test_that("multiple files", {
    config <- .testConfig(type="grm")
    
    x <- getobj(config["grm_file"])
    samp <- x$sample.id[1:10]

    config["grm_file"] <- paste(config["grm_file"], config["grm_file"])
    grm <- getGRM(config, sample.id=samp)
    expect_is(grm, "list")
    expect_equal(length(grm), 2)
    expect_equal(grm[[1]], grm[[2]])
    
    .cleanupConfig(config)
})

test_that("king", {
    config <- .testConfig(type="king")
    
    x <- getobj(config["king_file"])
    samp <- x$sample.id[1:10]
    grm <- getKinship(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "matrix")
    expect_equal(colnames(grm), samp)
    
    .cleanupConfig(config)
})

test_that("king_gds", {
    config <- .testConfig(type="king_gds")
    
    x <- openfn.gds(config["king_file"])
    samp <- read.gdsn(index.gdsn(x, "sample.id"))[1:10]
    closefn.gds(x)
    grm <- getKinship(config, sample.id=samp)
    expect_is(grm, "list")
    grm <- grm[[1]]
    expect_is(grm, "matrix")
    expect_equal(colnames(grm), samp)
    
    .cleanupConfig(config)
})
