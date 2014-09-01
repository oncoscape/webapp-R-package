print(load("CopyNumberGain29Genes.RData"))            # gainGenes
print(load("CopyNumberLoss66Genes.RData"))            # lossGenes
print(load("GBM.network.genes.RData"))                # GBM.net
print(load("mostVaryingQuintile594Genes.RData"))      # topSD
print(load("mutatedInGT5pc31Genes.RData"))            # mutGenes
print(load("overExpInGT5pcOfSamples203Genes.RData"))  # overGenes
print(load("underExpInGT5pcOfSamples62Genes.RData"))  # underGenes
length(unique(c(gainGenes, lossGenes, topSD, mutGenes, overGenes, underGenes)))  # 885
length(c(gainGenes, lossGenes, topSD, mutGenes, overGenes, underGenes))          # 985
