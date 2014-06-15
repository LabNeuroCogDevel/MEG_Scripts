function [ Stats, Clusters, Clust_Masks, Sig_Mask, Clust_Pvals, Sig_Pvals, Null_clusts_mass ] = MEG_Cluster_Stats( Data1, Data2, nPerm)
%Function to run cluster level statistics for MEG data.  This function will
%perform randomized permutation test, and find significant time or TFR
%clusters determined by cluster based statistics. The sum of test
%statistics (cluster mass) of clusters exceeded  p < .05 uncorrected
%threshold will be taken, and compare to cluster masses from a bootstrapped
%Null distribution. For details see As described in Maris and Oostenveld et
%al 2007.
%
%   Usage: [ Stats, Clusters, Clust_Masks, Sig_Mask, Clust_Pvals,
%   Sig_Pvals, Null_clusts_mass ] = MEG_Cluster_Stats( Data1, Data2, nPerm)
%
%   Input:
%   Data1 and Data2 are the input data. They could be different
%   conditions or different subject populations. The last dimesion is the
%   dimension to be permuted. If its evoke data, it should be time x
%   subject. If its TFR data, it should be time x freq x subject.
%
%   nPerm is the number of permutations, generally one should use > 1000.
%
%   Output:
%   Stats - the t stats for every data bin.
%   Clusters - clusters that that exceeded p < .05 uncorrected theshold.
%   Clust_Masks - a binary mask of uncorrected clusters for visualization
%   purposes.
%   Sig_Mask - Mask of significant clusters determined by corrected cluster
%   level statstistics.
%   Clust_Pvals - all p values from clusters.
%   Sig_Pvals - only the significant p values.
%   Null_clust_mass - Null distribution of cluster mass.
%
%
%   Last update by Kai. Aug 6, 2012.  

%peform permutation test.
[Stats, df, ~, surrog]=statcond({Data1 Data2},'mode','perm','naccu',nPerm);

%find critical test stat value at 97.5 percentile, two tail test.
tVal = icdf('t',0.95,df);

%two tail test, take the absolute
test_clusts = bwlabeln(abs(Stats)>tVal);

%find the test clusters
%test_clusts_mass = sum(abs(stats(test_clusts==1)))
Test_stat_clusts_mass = zeros(max(max(test_clusts)),1);
for j = 1:max(max(test_clusts))
    Test_stat_clusts_mass(j) = sum(abs(Stats(test_clusts==j)));
    %if curr_clust_mass>test_clusts_mass
    %    test_clusts_mass = curr_clust_mass
    %end
end

%find out about null data dimension
null_dimension = length(size(surrog));

%get distribution of cluster mass from null 
Null_clusts_mass = zeros(nPerm,1);
for i = 1:nPerm
    if null_dimension == 2
        null_data = surrog(:,i);
    elseif null_dimension == 3
        null_data = squeeze(surrog(:,:,i));
    else
        error('ERROR!!!! input dimension more then 3?')
    end
    
    null_clusts = bwlabeln(abs(null_data)>tVal);
    null_clust_mass = sum(abs(null_data(null_clusts==1)));
    
    for j = 2:max(null_clusts)
        curr_clust_mass = sum(abs(null_data(null_clusts==j)));
        if curr_clust_mass > null_clust_mass
            null_clust_mass = curr_clust_mass;
        end
    end
    Null_clusts_mass(i) = null_clust_mass;
end

%get p values for Test_stat_clusts_mass
Clust_Pvals = zeros(length(Test_stat_clusts_mass),1);
for i = 1:length(Test_stat_clusts_mass)
    Clust_Pvals(i) = (sum(Null_clusts_mass>Test_stat_clusts_mass(i)))./nPerm;
end

Sig_Mask = zeros(size(Stats));
if any(Clust_Pvals < 0.05)
    a = find(Clust_Pvals<0.05);
    for i = 1:length(a)
        tempMask = test_clusts==a(i);
        Sig_Mask = Sig_Mask + tempMask;
    end
    Sig_Pvals = Clust_Pvals(Clust_Pvals < 0.05);
else
    Sig_Pvals = [];
end


Clust_Masks = test_clusts > 0;
Clusters = test_clusts;

end

