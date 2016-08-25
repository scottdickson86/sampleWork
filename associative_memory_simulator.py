# -*- coding: utf-8 -*-
import math
import numpy as np
import copy

#*** Link Storage Module ***
# link Storage Module is a 3D matrix that saves neural 
# interconnections between clusters during learning.
# Since Python matrices are strictly 2D, we will use numpy arrays 
# to create a 2D array, where the internal arrays are also 2D arrays.
# The external arrays represent the RAM blocks; each RAM block stores 
#       neural interconnection between one pair of clusters.
#       Total number of external arrays = clusters*(clusters-1)
# The internal arrays (inside each RAM block) represent the 
#       neurons of a source cluster; each bit entry in the internal 
#       array represents the binary connection of the source neuron 
#       to a destination neuron in the destination cluster.
#       Total number of internal arrays = neurons in the source cluster

def initialize_linkStorageModule(nueronsPerCluster, ramBlocksTotal):
    sourceNeuron = np.zeros(nueronsPerCluster)  # internal array
    ramBlock = []                               # external array
    sourceNeuron_i = 0
    while sourceNeuron_i < nueronsPerCluster:
        ramBlock.append(sourceNeuron)
        sourceNeuron_i += 1
    linkStorageModule = []
    ramBlock_i = 0
    while ramBlock_i < ramBlocksTotal:
        linkStorageModule.append(ramBlock)
        ramBlock_i += 1
    return linkStorageModule

# This function decides the pairing of clusters in associative memory.
# One RAM block represents the links between one pair of clsuters.
# Total number of cluster pairings = total number of ramBlocks
def create_linkStorageModule_indexing(ramBlocksTotal, clustersTotal):
    ramBlock_i = 0
    clusterPairs = []
    while ramBlock_i < ramBlocksTotal:
        cluster1 = 0
        while cluster1 < clustersTotal:
            cluster2 = 0
            while cluster2 < clustersTotal:
                if cluster1 != cluster2:
                    sourceCluster = cluster1
                    destinationCluster = cluster2
                    clusterPairs.append([sourceCluster, destinationCluster])
                    ramBlock_i += 1
                cluster2 += 1
            cluster1 += 1
    return clusterPairs

# This function sets the binary connections in the linkStorageModule
# This is evoked each time a message (connection ID) is learned
def save_links(linkStorageModule, clusterPairs, subMessages):
    ramBlock_i = 0
    for eachPair in clusterPairs:
        sourceNeuron = int(subMessages[eachPair[0]],2)          #source neuron transformed form binary to int
        destinationNeuron = int(subMessages[eachPair[1]],2)     #destination neuron transformed form binary to int
        linkStorageModule[ramBlock_i][sourceNeuron][destinationNeuron]=1
        ramBlock_i += 1

# This function breaks down the full input message into sub-messages.
# Each sub-messge is assigned to one cluster during learning and decoding
# Sub-message lenght for input clusters are sometimes not equal in lenght
# to that of the output cluster. 
def break_down_input_message(inputMessageFull, bitsPerCluster, outputBitsPerCluster, clustersTotal):
    subM_i = 0
    subMessages = []
    while subM_i < clustersTotal:
        clusterBits = ""
        start_i = 0
        end_i = 0
        #for input clusters: use bitsPerCluster
        if subM_i < (clustersTotal-1):              
            start_i = (subM_i*bitsPerCluster)
            end_i = start_i + bitsPerCluster
            clusterBits = inputMessageFull[start_i:end_i]
        #for output cluster (last cluster): use outputBitsPerCluster
        elif subM_i == (clustersTotal-1):           
            start_i = (subM_i*bitsPerCluster)
            end_i = start_i + outputBitsPerCluster
            clusterBits = inputMessageFull[start_i:end_i]
        subMessages.append(clusterBits)
        subM_i += 1
    return subMessages 

# This function erases the sub-message assigned to the output cluster,
# creating a partially erased version of inputSetComplete.
# The output of this function, inputSetErased, will be used
# as input to SD-SCN for the decoding process
def erase_output_submessage(inputSetComplete, clustersTotal, erasedClusterString):
    inputSetErased = []
    input_i = 0
    outputCluster_i = int(clustersTotal-1)   #output cluster index is always last
    while input_i < len(inputSetComplete):          
        subMessages = inputSetComplete[input_i]
        subMessages[outputCluster_i]  = erasedClusterString
        inputSetErased.append(subMessages)
        input_i += 1
    return inputSetErased


# This function models the behavior of the SD-SCN Local Decoder.
# For each cluster, nueron with index equal to the interger equivalent
# of the assigned binary sub-message during search query is activated. 
# If the sub-message is specified, only one neuron is activated.
# If the sub-message is erased (output cluster), all nuerons are activated
# and Global Decoding is performed. 
def perform_local_decoding(inputMessageSearch, erasedClusterString, neuronsPerCluster):
    candidateNeuronsPerCluster = []                       #stores active neurons per cluster
    subMessage_i = 0
    for subMessage in inputMessageSearch:       
        #If sub-message is erased, all neurons are candidates
        if subMessage == erasedClusterString:
            allNeurons = np.arange(0, neuronsPerCluster)
            candidateNeuronsPerCluster.append(allNeurons)
        else:
            activeNeuron = int(subMessage, 2)
            candidateNeuronsPerCluster.append([activeNeuron])
        subMessage_i += 1
    return candidateNeuronsPerCluster

# This function models the behavior of the Global Decoder.
# For each cluster, the candidate neurons (generated from 
# the Local Decoder step) can remain active if and only if it is 
#linked to at least one active neuron in each of the other clusters. 
# A neuron in one cluster must be linked to at least one neuron in 
# each of the remaining clusters in order to remain active. 
def perform_global_decoding(candidateNeuronsPerCluster, clusterPairs, linkStorageModule):
    linkedActiveNeuronsPerCluster = []
    cluster_i = 0
    for cluster in candidateNeuronsPerCluster:
        linkedActiveNeuronsPerCluster.append([])    #empty internal array represents current cluster, which will hold linked active neurons
        #if there's only candidate neuron, it stays active
        if len(cluster)==1:         
            linkedActiveNeuronsPerCluster[cluster_i].append(cluster[0]) 
        #if there's more, only candidate neurons that are linked to other active neurons stay active
        elif len(cluster)>1:  
            for candidateNeuron_i in cluster:
                stayActive = True
                ramBlock_i = 0
                for eachPair in clusterPairs:
                    clusterSource = eachPair[0]
                    clusterDestination = eachPair[1] 
                    if cluster_i == clusterSource:#compare
                        linkFound = False
                        for candidateNeuronDestinationCluster_i in candidateNeuronsPerCluster[clusterDestination]:
                            if linkStorageModule[ramBlock_i][candidateNeuron_i][candidateNeuronDestinationCluster_i]==1:
                                linkFound = True 
                                break #only one link to an active neuron in the destination cluster is needed to keep a neuron in the source cluster active
                        if not linkFound: #search finished; 
                            stayActive = False
                            break # no need to continue finding links toward other clusters if candidate neuron doesn't have a link to the currrent destination cluster 
                    ramBlock_i += 1
                if stayActive:
                    linkedActiveNeuronsPerCluster[cluster_i].append(candidateNeuron_i)
                #evaluate next candidate neuron in the current source cluster
        cluster_i += 1
    return linkedActiveNeuronsPerCluster


#Evaluate the associative memory design governed by each set
#of configuration. One set of configuration = numbers at equal
#indexes in each of the arrays below

inputMessageBaseWidthConfigs =          [104, 104, 104, 72, 56, 56, 56, 24]
clustersTotalConfigs =                  [9, 13, 17, 9, 5, 7, 9, 3]
inputClusterSubMessageWidthConfigs =    [12, 8, 6, 8, 12, 8, 6, 8]

inputMessageBaseWidthInternalConfigs =  [] #internal padding for output cluster, always + 4
for entry in inputMessageBaseWidthConfigs:
    inputMessageBaseWidthInternalConfigs.append(entry+4) 

#These parameters are constant:
outputBitsPerCluster = 12
actualClassWidth = 3#bits
classWidth = int(math.pow(2, actualClassWidth)) #one hot encoding format
class_neuron_oth_dict = {"16":4, "8":3, "1":0, "32":5, "128":7, "4":2, "2":1}
sourceFile = "ground_truth_binary_bits_component_frequency_sorted.txt"

erasedClusterString = "x"*outputBitsPerCluster
neuronsPerCluster = int(math.pow(2, outputBitsPerCluster))


configIndex = 0

while configIndex < len(inputMessageBaseWidthConfigs):

    print ("configIndex: ", configIndex)
    #*******SD-SCN configuration
    inputMessageBaseWidth = inputMessageBaseWidthConfigs[configIndex] 
    inputMessageBaseWidthInternal = inputMessageBaseWidthInternalConfigs[configIndex] 
    clustersTotal = clustersTotalConfigs[configIndex] 
    ramBlocksTotal = (clustersTotal)*(clustersTotal-1)
    
    #initialize linkStorageModule
    linkStorageModule = np.array(initialize_linkStorageModule(neuronsPerCluster, ramBlocksTotal))
    clusterPairs = create_linkStorageModule_indexing(ramBlocksTotal, clustersTotal)

    inputSetComplete = []     #contains clustered sub-messages (array of array)
    zeroPaddingTotal = inputMessageBaseWidthInternal - inputMessageBaseWidth 
    zeroPaddingString = "0"*zeroPaddingTotal
    
    #Start of full message storage to SD-SCN
    #input messages are read from a file
    print ("Storing complete messages into SD-SCN...")
    inputFile = open(sourceFile, "r")
    for line in inputFile:
        inputMessageFull = line.strip()
        #add zero-padding
        inputMessageFull = inputMessageFull[0:len(inputMessageFull)-classWidth]+zeroPaddingString+inputMessageFull[len(inputMessageFull)-classWidth:len(inputMessageFull)]
        inputMessageClustered = break_down_input_message(inputMessageFull, inputClusterSubMessageWidthConfigs[configIndex], outputBitsPerCluster, clustersTotal)
        inputSetComplete.append(inputMessageClustered)
        #store into linkStorageModule
        linkStorageModule = save_links(linkStorageModule, clusterPairs, inputMessageClustered)
    inputFile.close()
    print ("Done.")
    #end of data storage
    
    #Start of message retrieval from SD-SCN
    #first, erased all output messages; the erased sub-message
    #in the output cluster is going to be decoded by the 
    # Local and Global Decoders
    print ("Start of message retrieval phase...")
    #first create partial input messages
    messages_count = len(inputSetComplete)
    print ("creating partial messages as input for search query...")
    inputSetErased = erase_output_submessage(inputSetComplete, clustersTotal, erasedClusterString) 
    input_subset_i = 0

    inputMessagesTotal = 0
    successfulMatchTotal = 0
    errorsTotal = 0
    beta = 1 #beta is 1 if it only takes LD to generate a match, else measure after first GD
    
    for inputMessageSearch in inputSetErased:
        #START of local decoding
        candidateNeuronsPerCluster = perform_local_decoding(inputMessageSearch, erasedClusterString, neuronsPerCluster)
        localDecoderOut = True              #local decoder just completed
        #START of GLobal decoding
        #Global decoding must continue to deactivate neurons
        #if the number of active neurons now is less than that of the previous run
        continueDeactivating = False        #assume a single round of GD generates a match
        activeNeuronsTotalPrevious = 0
        for eachCluster in candidateNeuronsPerCluster:
            activeCandidateNeuronsTotal = len(eachCluster)
            if activeCandidateNeuronsTotal>1:
                continueDeactivating = True
            activeNeuronsTotalPrevious = activeNeuronsTotalPrevious + activeCandidateNeuronsTotal
        while continueDeactivating:
            linkedActiveNeuronsPerCluster = perform_global_decoding(candidateNeuronsPerCluster, clusterPairs, linkStorageModule)
            if localDecoderOut:
                for eachCluster in linkedActiveNeuronsPerCluster:
                    activeCandidateNeuronsTotal = len(eachCluster)
                    if activeCandidateNeuronsTotal>beta:
                        beta = activeCandidateNeuronsTotal
            #Generate match
            cluster_i = 0
            matchFound = True
            activeNeuronsTotal = 0
            for cluster in linkedActiveNeuronsPerCluster:
                if len(cluster)>1:
                    matchFound = False
                activeNeuronsTotal = activeNeuronsTotal + len(cluster)
                cluster_i += 1
            if matchFound:
                successfulMatchTotal += 1
                continueDeactivating = False    
            if not matchFound:
                if activeNeuronsTotal<activeNeuronsTotalPrevious:
                    continueDeactivating = True
                    localDecoderOut = False     #data from localDecoder is no longer needed after first run of Global Decoder 
                    #deep copy is necessary to avoid referencing data from Local Decoder
                    #this way, deactivated neurons remain deactivated                    
                    candidateNeuronsPerCluster = copy.deepcopy(linkedActiveNeuronsPerCluster)
                    activeNeuronsTotalPrevious = activeNeuronsTotal
                else:#stop attemtping to deactivate neurons if the number of active nuerons hasn't changed since the last Global Decoding run 
                    continueDeactivating = False
                    errorsTotal += 1
        inputMessagesTotal += 1

    #write results
    outputFile = "simulation_results_"+str(inputMessageBaseWidth)+"bits_"+str(clustersTotal)+"clustersTotal.txt"
    outputLog = open(outputFile, "w")
    outputLog.write ("---------------\n")
    outputLog.write ("Input message length :"+str(inputMessageBaseWidth)+"\n")
    outputLog.write ("Total # messages     :"+str(inputMessagesTotal)+"\n")
    outputLog.write ("Total # clusters     :"+str(clustersTotal)+ + "\n")
    outputLog.write ("neurons per cluster  :"+str(neuronsPerCluster)+"\n")
    outputLog.write ("---------------\n")
    outputLog.write ("beta                 :"+str(beta)+"\n")
    outputLog.write ("Total # of matches   :"+str(successfulMatchTotal)+"\n")
    outputLog.write ("Total # of errors    :"+str(errorsTotal)+"\n")
    outputLog.close()
    configIndex += 1


