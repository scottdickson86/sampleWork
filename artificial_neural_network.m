%constants
total_connections = 494021; %these are the total number of connections in the file 
total_samples = 2000; %we want to only use these much for training and testing
%below will be the indexes of the random samples that will be taken from the the file
random_samples = randperm(total_connections, total_samples);

%read data from file line by line
fileID = fopen('kddcup.data_10_percent','r');
%write random samples into a new file; this will be added into a matrix
%later
fileIDnew = fopen('kddcup_train_test','w');
%create matrix for total_samples
tline = fgetl(fileID); %line tracker for the dataset file
connection_count = 1;
while ischar(tline)
    %tline is represents a line from file, i.e., a connection from the
    %dataset
    %only copy sample to new file if row_count is in the pre-identified random
    %indexes in random_samples
    if ismember(connection_count, random_samples)
        fprintf(fileIDnew,strcat(tline,'\n'));
    end
    tline = fgetl(fileID);
    connection_count = connection_count + 1;
    if connection_count <= total_connections
        disp (strcat('Connection #: ', num2str(connection_count)));
    end
end

fclose(fileID);
fclose(fileIDnew);

dataSet = []; %matrix to contain all total_samples
fileID = fopen('kddcup_train_test','r');
tline = fgetl(fileID); %line tracker for the dataset file
disp ('Saving samples to matrix dataSet...');
row_count = 1;
while ischar(tline)
    tline_delim = strsplit(tline, ',');
    %tline_delim - a vector containing the separated features and label for one connection
    dataSet = [dataSet; tline_delim];
    tline = fgetl(fileID);
    row_count = row_count +1 
end
fclose(fileID);

% dataSet is now a matrix; 
% convert symbolic features to numeric
disp('Converting symbolic features to numeric...')
for indexes_symbolic = [2 3 4 42] %42 - the target labels
    if indexes_symbolic == 2
        new_column_entries = [];
        for column_entry = dataSet(:,indexes_symbolic)'
            if logical(strcmp(column_entry, 'tcp'))
                new_column_entries = [new_column_entries; '0'];
            elseif strcmp(column_entry, 'udp')
                new_column_entries = [new_column_entries; '1'];
            elseif strcmp(column_entry, 'icmp')
                new_column_entries = [new_column_entries; '2'];
            else
                disp(strcat('Error at symbolic index :', num2str(indexes_symbolic)));
                disp(column_entry);
            end
            row_count = row_count + 1;
        end
        dataSet(:,indexes_symbolic) = cellstr(new_column_entries);
    elseif indexes_symbolic == 3
        new_column_entries = [];
        row_count = 1;
        for column_entry = dataSet(:,indexes_symbolic)'
            if strcmp(column_entry, 'http')
                new_column_entries = [new_column_entries; '00'];
            elseif strcmp(column_entry, 'smtp')
                new_column_entries = [new_column_entries; '01'];
            elseif strcmp(column_entry, 'finger')
                new_column_entries = [new_column_entries; '02'];
            elseif strcmp(column_entry, 'domain_u')
                new_column_entries = [new_column_entries; '03'];
            elseif strcmp(column_entry, 'auth')
                new_column_entries = [new_column_entries; '04'];
            elseif strcmp(column_entry, 'telnet')
                new_column_entries = [new_column_entries; '05'];
            elseif strcmp(column_entry, 'ftp')
                new_column_entries = [new_column_entries; '06'];
            elseif strcmp(column_entry, 'eco_i')
                new_column_entries = [new_column_entries; '07'];
            elseif strcmp(column_entry, 'ntp_u')
                new_column_entries = [new_column_entries; '08'];    
            elseif strcmp(column_entry, 'ecr_i')
                new_column_entries = [new_column_entries; '09'];
            elseif strcmp(column_entry, 'other')
                new_column_entries = [new_column_entries; '10'];
            elseif strcmp(column_entry, 'private')
                new_column_entries = [new_column_entries; '11'];  
            elseif strcmp(column_entry, 'pop_3')
                new_column_entries = [new_column_entries; '12'];
            elseif strcmp(column_entry, 'ftp_data')
                new_column_entries = [new_column_entries; '13'];
            elseif strcmp(column_entry, 'rje')
                new_column_entries = [new_column_entries; '14'];
            elseif strcmp(column_entry, 'time')
                new_column_entries = [new_column_entries; '15'];
            elseif strcmp(column_entry, 'mtp')
                new_column_entries = [new_column_entries; '16'];
            elseif strcmp(column_entry, 'link')
                new_column_entries = [new_column_entries; '17'];
            elseif strcmp(column_entry, 'remote_job')
                new_column_entries = [new_column_entries; '18'];
            elseif strcmp(column_entry, 'gopher')
                new_column_entries = [new_column_entries; '19'];
            elseif strcmp(column_entry, 'ssh')
                new_column_entries = [new_column_entries; '20'];
            elseif strcmp(column_entry, 'name')
                new_column_entries = [new_column_entries; '21'];
            elseif strcmp(column_entry, 'whois')
                new_column_entries = [new_column_entries; '22'];
            elseif strcmp(column_entry, 'domain')
                new_column_entries = [new_column_entries; '23'];
            elseif strcmp(column_entry, 'login')
                new_column_entries = [new_column_entries; '24'];
            elseif strcmp(column_entry, 'imap4')
                new_column_entries = [new_column_entries; '25'];
            elseif strcmp(column_entry, 'daytime')
                new_column_entries = [new_column_entries; '26'];
            elseif strcmp(column_entry, 'ctf')
                new_column_entries = [new_column_entries; '27'];
            elseif strcmp(column_entry, 'nntp')
                new_column_entries = [new_column_entries; '28'];
            elseif strcmp(column_entry, 'shell')
                new_column_entries = [new_column_entries; '29'];
            elseif strcmp(column_entry, 'IRC')
                new_column_entries = [new_column_entries; '30'];
            elseif strcmp(column_entry, 'nnsp')
                new_column_entries = [new_column_entries; '31'];
            elseif strcmp(column_entry, 'http_443')
                new_column_entries = [new_column_entries; '32'];
            elseif strcmp(column_entry, 'exec')
                new_column_entries = [new_column_entries; '33'];
            elseif strcmp(column_entry, 'printer')
                new_column_entries = [new_column_entries; '34'];
            elseif strcmp(column_entry, 'efs')
                new_column_entries = [new_column_entries; '35'];
            elseif strcmp(column_entry, 'courier')
                new_column_entries = [new_column_entries; '36'];
            elseif strcmp(column_entry, 'uucp')
                new_column_entries = [new_column_entries; '37'];
            elseif strcmp(column_entry, 'klogin')
                new_column_entries = [new_column_entries; '38'];
            elseif strcmp(column_entry, 'kshell')
                new_column_entries = [new_column_entries; '39'];
            elseif strcmp(column_entry, 'echo')
                new_column_entries = [new_column_entries; '40'];
            elseif strcmp(column_entry, 'discard')
                new_column_entries = [new_column_entries; '41'];
            elseif strcmp(column_entry, 'systat')
                new_column_entries = [new_column_entries; '42'];
            elseif strcmp(column_entry, 'supdup')
                new_column_entries = [new_column_entries; '43'];
            elseif strcmp(column_entry, 'iso_tsap')
                new_column_entries = [new_column_entries; '44'];
            elseif strcmp(column_entry, 'hostnames')
                new_column_entries = [new_column_entries; '45'];
            elseif strcmp(column_entry, 'csnet_ns')
                new_column_entries = [new_column_entries; '46'];
            elseif strcmp(column_entry, 'pop_2')
                new_column_entries = [new_column_entries; '47'];
            elseif strcmp(column_entry, 'sunrpc')
                new_column_entries = [new_column_entries; '48'];
            elseif strcmp(column_entry, 'uucp_path')
                new_column_entries = [new_column_entries; '49'];
            elseif strcmp(column_entry, 'netbios_ns')
                new_column_entries = [new_column_entries; '50'];
            elseif strcmp(column_entry, 'netbios_ssn')
                new_column_entries = [new_column_entries; '51'];
            elseif strcmp(column_entry, 'netbios_dgm')
                new_column_entries = [new_column_entries; '52'];
            elseif strcmp(column_entry, 'sql_net')
                new_column_entries = [new_column_entries; '53'];
            elseif strcmp(column_entry, 'vmnet')
                new_column_entries = [new_column_entries; '54'];
            elseif strcmp(column_entry, 'bgp')
                new_column_entries = [new_column_entries; '55'];
            elseif strcmp(column_entry, 'Z39_50')
                new_column_entries = [new_column_entries; '56'];
            elseif strcmp(column_entry, 'ldap')
                new_column_entries = [new_column_entries; '57'];
            elseif strcmp(column_entry, 'netstat')
                new_column_entries = [new_column_entries; '58'];
            elseif strcmp(column_entry, 'urh_i')
                new_column_entries = [new_column_entries; '59'];
            elseif strcmp(column_entry, 'X11')
                new_column_entries = [new_column_entries; '60'];
            elseif strcmp(column_entry, 'urp_i')
                new_column_entries = [new_column_entries; '61'];
            elseif strcmp(column_entry, 'pm_dump')
                new_column_entries = [new_column_entries; '62'];
            elseif strcmp(column_entry, 'tftp_u')
                new_column_entries = [new_column_entries; '63'];
            elseif strcmp(column_entry, 'tim_i')
                new_column_entries = [new_column_entries; '64'];
            elseif strcmp(column_entry, 'red_i')
                new_column_entries = [new_column_entries; '65'];
            else
                disp(strcat('Error ', num2str(indexes_symbolic)))
            end
        end
        dataSet(:,indexes_symbolic) = cellstr(new_column_entries);
    elseif indexes_symbolic == 4
        new_column_entries = [];
        for column_entry = dataSet(:,indexes_symbolic)'
            if strcmp(column_entry, 'SF')
                new_column_entries = [new_column_entries; '00'];
            elseif strcmp(column_entry, 'S1')
                new_column_entries = [new_column_entries; '01'];
            elseif strcmp(column_entry, 'REJ')
                new_column_entries = [new_column_entries; '02'];
            elseif strcmp(column_entry, 'S2')
                new_column_entries = [new_column_entries; '03'];
            elseif strcmp(column_entry, 'S0')
                new_column_entries = [new_column_entries; '04'];
            elseif strcmp(column_entry, 'S3')
                new_column_entries = [new_column_entries; '05'];
            elseif strcmp(column_entry, 'RSTO')
                new_column_entries = [new_column_entries; '06'];
            elseif strcmp(column_entry, 'RSTR')
                new_column_entries = [new_column_entries; '07'];
            elseif strcmp(column_entry, 'RSTOS0')
                new_column_entries = [new_column_entries; '08'];
            elseif strcmp(column_entry, 'OTH')
                new_column_entries = [new_column_entries; '09'];
            elseif strcmp(column_entry, 'SH')
                new_column_entries = [new_column_entries; '10'];
            else
                disp(strcat('Error ', num2str(indexes_symbolic)))
            end
        end
        dataSet(:,indexes_symbolic) = cellstr(new_column_entries);
    elseif indexes_symbolic == 42
        new_column_entries = [];
        for column_entry = dataSet(:,indexes_symbolic)'
            if strcmp(column_entry, 'normal.')
                new_column_entries = [new_column_entries; '0'];
            else
                new_column_entries = [new_column_entries; '1'];
            end
        end
        dataSet(:,indexes_symbolic) = cellstr(new_column_entries);
    end
       
end

disp('Converting entire data set to numerical figures for ANN training...');
inputs = [];
targets = [];
fileIDfinal = fopen('kddcup_train_test_final','w');
row_count = 1;
while row_count <= total_samples
    row_count
    row = zeros(1,41);
    line = '';
    entry_count = 1;
    for entry = dataSet(row_count,:)
        if entry_count <= 41
            row(entry_count) = str2double(entry);
        else
            targets = [targets; str2double(entry)];
        end
        line = strcat(line, num2str(str2double(entry)), ',');
        entry_count = entry_count + 1;
    end
    inputs = [inputs; row];
    fprintf(fileIDfinal, strcat(char(line),'\n'));  
    row_count = row_count + 1;
end
fclose(fileIDfinal);
inputs = inputs';
targets = targets';
disp('Training neural network...');
% specifying network design
hidden_layers_total = 10;
ann_design = patternnet(hidden_layers_total);
% dividing dataset for testing, training, and validation 
ann_design.divideParam.trainRatio = 70/100;
ann_design.divideParam.valRatio = 15/100;
ann_design.divideParam.testRatio = 15/100;
% actual network training begins here
[ann_design,training_out] = train(ann_design,inputs,targets);
% actual testing starts here
outputs = ann_design(inputs);
err_detected = gsubtract(targets,outputs);
perf_measured = perform(ann_design,targets,outputs)
% network design view 
view(ann_design)
% plot results 
 figure, plotperform(training_out)
 figure, plottrainstate(training_out)
 figure, plotconfusion(targets,outputs)
 figure, ploterrhist(err_detected)