//
//  main.cpp
//  CacheSimulator
//
//  Created by Scott Dickson Dagondon on 2/10/15.
//  Copyright (c) 2015 Scott Dickson Dagondon. All rights reserved.
//

#include <iostream>     // std::cout, std::fixed
#include <stdlib.h>     /* srand, rand */
#include <time.h>       /* time */
#include <string.h>     /* strcat*/
#include <iomanip>      /*std::setprecision*/
#include <math.h>
#define SLOTS 128
#define CACHE_LINE 32
#define TAG_LENGTH_FA 27
#define TAG_LENGTH_DM 20
#define TAG_LENGTH_SA 23
#define SLOT_LENGTH_DM 7
#define SET_LENGTH_SA 4
#define SLOT_INDEX_SA 8
#define SET_INDEX_SA 16
#define OFFSET_LENGTH 5
#define INPUT_SIZE 1
int least_recently_used [SLOTS]; //records least_recently_used rannkings of cache slots
int least_recently_used_min = 0; //any slot with least_recently_used[slot_i] = least_recently_used_min gets replaced
int cache [SLOTS][1+CACHE_LINE]; //1+cache_line - "1" for valid bit
int set_associative_slot_index [SLOTS];
int set_associative_set_index [SLOTS];
int address [SLOTS*INPUT_SIZE][CACHE_LINE]; //3 times more inputs as there are slots

int choose_cache_type(){
    std::cout << "Choose the cache simulator type:\n";
    std::cout << "   (1) Fully associative\n";
    std::cout << "   (2) Direct mapped\n";
    std::cout << "   (3) Set associative\n";
    std::cout << "Input choice: ";
    int choice;
    std::cin >> choice;
    //std::cout << choice << "\n";
    if ((choice!=1)&&(choice!=2)&&(choice!=3)){
        std::cout << "Invalid choice.\n";
        exit(0);
    }else{
        if (choice == 1) {
            std::cout << "Fully associative cache chosen.\n";
        }
        else if (choice == 2) {
            std::cout << "Direct mapped cache chosen.\n";
        }else {
            std::cout << "Set associative cache chosen.\n";
        }
    }
    return choice;
}

void initialize_input(){
    /* initialize random seed: */
    srand (time_t(NULL));
    for (int i=0; i<(SLOTS*INPUT_SIZE); i++){
        for (int j=0; j<CACHE_LINE; j++){
            int bit = rand() % 2;
            address[i][j] = bit; //generate number between 1 and 0
        }
    }
    //to allow cache hit,
    //replace 80 percent of the total number of inputs with contents of first row
    double target_repetition = 0.30; //80 percent
    int replacements_limit = (int)(SLOTS*INPUT_SIZE*target_repetition);
    //std::cout << "replacements_limit: " << replacements_limit << ".\n";
    int row [SLOTS*INPUT_SIZE];
    for (int row_i=0; row_i<(SLOTS*INPUT_SIZE); row_i++){
        row[row_i] = row_i;
    }
    std::random_shuffle(std::begin(row), std::end(row));
    //copy contents of row 0
    int duplicate_row [CACHE_LINE];
    for (int element_i=0; element_i<CACHE_LINE; element_i++){
        duplicate_row[element_i] = address[0][element_i];
    }
    int i = 0;
    while (i < replacements_limit){
        /*std::cout << "row: " << row[i] << ".\n";
        std::cout << "before: ";
        for (int char_i=0; char_i<CACHE_LINE; char_i++){
            std::cout << address[row[i]][char_i];
        }
        std::cout << "\n";*/
        for (int char_i=0; char_i<CACHE_LINE; char_i++){
            address[row[i]][char_i] = duplicate_row[char_i];
        }
        /*std::cout << "after : ";
        for (int char_i=0; char_i<CACHE_LINE; char_i++){
            std::cout << address[row[i]][char_i];
        }
        std::cout << "\n";*/
        i++;
    }
    /*for (int row_i=0; row_i<(SLOTS*INPUT_SIZE); row_i++){
        for (int col_i=0; col_i<CACHE_LINE; col_i++){
            std::cout << address[row_i][col_i];
        }
        std::cout << "\n";
    }*/
}

void show_array_contents(int array[][CACHE_LINE]){
    int i, j;
    for (i=0; i<SLOTS; i++){
        for (j=0; j<CACHE_LINE; j++){
            std::cout << array[i][j];
        }
        std::cout << "\n";
    }
}

void retrieve_cache_data(int cache_type){
    double cache_hit = 0.0;
    std::cout << std::fixed;
    std::cout << std::setprecision(2);
    //if cache_type is set associative, initialization is required
    //cache slots must be grouped into sets and the 3-bits immediatly to the left
    //of the set represents the slot bits
    //the rest of the cache types do not require initialization
    if (cache_type==3) {
        //group cache into sets
        int slot_slot = 0;
        int slot_set = 0;
        for (int slot_i=0; slot_i<SLOTS; slot_i++)
        {
            set_associative_slot_index[slot_i] = slot_slot;
            set_associative_set_index[slot_i] = slot_set;
            slot_slot++;
            slot_set++;
            if (slot_slot == SLOT_INDEX_SA){
                slot_slot = 0;
            }
            if (slot_set == SET_INDEX_SA){
                slot_set = 0;
            }
        }
    }
    for (int input_i=0; input_i<(SLOTS*INPUT_SIZE); input_i++){
        //extract tag for fully associative
        //extract tag and slot for direct mapped
        //extract tag and set for set associative
        std::string tag = "";
        std::string slot = "";
        int slot_dm = 0;
        std::string set = "";
        int set_sa = 0;
        if (cache_type == 1){
            for (int char_i=0; char_i<TAG_LENGTH_FA; char_i++){
                tag = tag + std::to_string(address[input_i][char_i]);
            }
        }else if (cache_type == 2){
            for (int char_i=0; char_i<TAG_LENGTH_DM; char_i++){
                tag = tag + std::to_string(address[input_i][char_i]);
            }
            for (int char_i=TAG_LENGTH_DM; char_i<TAG_LENGTH_DM+SLOT_LENGTH_DM; char_i++){
                slot = slot + std::to_string(address[input_i][char_i]);
            }
        }else if (cache_type == 3){
            for (int char_i=0; char_i<TAG_LENGTH_SA; char_i++){
                tag = tag + std::to_string(address[input_i][char_i]);
            }
            for (int char_i=TAG_LENGTH_SA; char_i<TAG_LENGTH_SA+SET_LENGTH_SA; char_i++){
                set = set + std::to_string(address[input_i][char_i]);
            }
        }
        
        //extract offset
        std::string offset = "";
        for (int char_i=TAG_LENGTH_FA; char_i<(TAG_LENGTH_FA+OFFSET_LENGTH); char_i++){
            offset = offset + std::to_string(address[input_i][char_i]);
        }
        //search cache
        bool match_found = false;
        //fully associative cache checks all vaid bits (at the same time in practice)
        //valid bit is at index [slot_i]0
        if (cache_type == 1){
            for (int slot_i=0; slot_i<SLOTS; slot_i++){
                if (cache[slot_i][0] == 1){//check slots only with set valid bit
                    //std::cout << "valid bit found at slot_i: "<< slot_i<< ".\n";
                    //extract slot tag
                    std::string slot_tag = "";
                    for (int char_i=1; char_i<(TAG_LENGTH_FA+1); char_i++){
                        slot_tag = slot_tag + std::to_string(cache[slot_i][char_i]);
                    }
                    //std::cout <<"slot tag: "<< slot_tag <<"\n";
                    //std::cout <<"addr tag: "<< tag <<"\n";
                    if (slot_tag == tag){
                        //match! one slot saves one tag-offset combo
                        //if the tags match for the current slot, it is assumed that the offset is correct
                        cache_hit++;
                        match_found = true;
                        std::cout << "cache access :" << input_i+1 << "\n";
                        std::cout << "...match found at slot_i: " << slot_i << "\n";
                        std::cout << "...input tag: " << tag << "\n";
                        std::cout << "...cache["<<slot_i<<"] : ";
                        for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                            std::cout << cache[slot_i][char_i];
                        }
                        std::cout << "\n";
                        std::cout << "...cache hit (hit rate: " << std::to_string((cache_hit/(double)(input_i+1))*100) << "%).\n";
                        //update least_recenlty_used score for slot
                        least_recently_used[slot_i] = least_recently_used[slot_i] + 1;
                        //std::cout << "least_recently_used[slot_i]: " << least_recently_used[slot_i] << ".\n";
                        break;
                    }
                }
            }
        }
        //direct mapped cache know which slots to check so there's no need to check every single slot for a match
        else if (cache_type==2){
            //convert slot string to binary to get the slot index
            int power = SLOT_LENGTH_DM - 1;
            int slot_i = 0;
            for (int char_i=0; char_i<SLOT_LENGTH_DM; char_i++)
            {
                int bit = std::atoi(slot.substr(char_i,1).c_str());
                slot_i = slot_i + (bit*pow(2,power));
                power--;
            }
            slot_dm = slot_i;
            //check if tag matches
            std::string slot_tag = "";
            for (int char_i=1; char_i<(TAG_LENGTH_DM+1); char_i++){
                slot_tag = slot_tag + std::to_string(cache[slot_i][char_i]);
            }
            if (slot_tag == tag){
                //match! one slot saves one tag-offset combo
                //if the tags match for the current slot, it is assumed that the offset is correct
                cache_hit++;
                match_found = true;
                std::cout << "cache access :" << input_i+1 << "\n";
                std::cout << "...match found at slot_i: " << slot_i << "\n";
                std::cout << "...input slot: " << slot << "(" << slot_dm << ")\n";
                std::cout << "...cache["<<slot_i<<"] : ";
                for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                    std::cout << cache[slot_i][char_i];
                }
                std::cout << "\n";
                std::cout << "...cache hit (hit rate: " << std::to_string((cache_hit/(double)(input_i+1))*100) << "%).\n";
                //update least_recenlty_used score for slot
                least_recently_used[slot_i] = least_recently_used[slot_i] + 1;
                //std::cout << "least_recently_used[slot_i]: " << least_recently_used[slot_i] << ".\n";
            }
        }
        //set associative, extract all slots from that share the same set
        //slot refers to the the 3 bits immediately to the left of set bits
        else if (cache_type==3){
            //convert set to int
            int power = SET_LENGTH_SA - 1;
            int set_int = 0;
            for (int char_i=0; char_i<SET_LENGTH_SA; char_i++)
            {
                int bit = std::atoi(set.substr(char_i,1).c_str());
                set_int = set_int + (bit*pow(2,power));
                power--;
            }
            //std::cout << "set int: " << set_int << ".\n";
            set_sa = set_int;
            for (int slot_i=0; slot_i<SLOTS; slot_i++){
                if (set_associative_set_index[slot_i]==set_int){
                    //compare tag
                    std::string slot_tag = "";
                    for (int char_i=1; char_i<(TAG_LENGTH_SA+1); char_i++){
                        slot_tag = slot_tag + std::to_string(cache[slot_i][char_i]);
                    }
                    if (slot_tag == tag){
                        //match! one slot saves one tag-offset combo
                        //if the tags match for the current slot, it is assumed that the offset is correct
                        cache_hit++;
                        match_found = true;
                        std::cout << "cache access :" << input_i+1 << "\n";
                        std::cout << "...match found at slot_i: " << slot_i << "\n";
                        std::cout << "...input set: " << set << "(" << set_sa << ")\n";
                        std::cout << "...cache["<<slot_i<<"] : ";
                        for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                            std::cout << cache[slot_i][char_i];
                        }
                        std::cout << "\n";
                        std::cout << "...cache hit (hit rate: " << std::to_string((cache_hit/(double)(input_i+1))*100) << "%).\n";
                        //update least_recenlty_used score for slot
                        least_recently_used[slot_i] = least_recently_used[slot_i] + 1;
                        std::cout << "...least_recently_used[" << slot_i << "]: " << least_recently_used[slot_i] << ".\n";
                        break;
                    }
                }
            }
        }
        if (!match_found){
            std::cout << "cache access :" << input_i+1 << "\n";
            std::cout << "...cache miss (hit rate: " << std::to_string((cache_hit/(double)(input_i+1))*100) << "%).\n";
            //store data to cache
            //fully associative cache checks all vaid bits (at the same time in practice)
            //valid bit is at index [slot_i]0
            if (cache_type==1){
                bool data_stored = false;
                for (int slot_i=0; slot_i<SLOTS; slot_i++){
                    if (cache[slot_i][0] == 0){//check if slot is free to save
                        /*std::cout << "before: ";
                        for (int char_i=0; char_i<CACHE_LINE+1; char_i++){
                            std::cout << cache[slot_i][char_i];
                        }
                        std::cout << "\n";*/
                        //set valid bit
                        cache[slot_i][0] = 1;
                        //copy data to cache
                        for (int char_i=1; char_i<(CACHE_LINE+1); char_i++){
                            cache[slot_i][char_i] = address[input_i][char_i-1];
                        }
                        data_stored = true;
                        std::cout << "...input tag: " << tag << "\n";
                        std::cout << "...data copied to cache at slot_i: "<<slot_i<<".\n";
                        std::cout << "...cache["<<slot_i<<"] : ";
                        for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                            std::cout << cache[slot_i][char_i];
                        }
                        std::cout << "\n";
                        //update least_recently_used score for slot
                        least_recently_used[slot_i] = least_recently_used[slot_i] + 1;
                        break;
                    }
                }
                //std::cout << !data_stored << "\n";
                if (!data_stored){//all slots have saved data
                    //find lowest least_recently_used score
                    int min = least_recently_used[0]; //assume first index is the smallest least_recently_used score and then update accordingly using the for-loop below
                    for (int slot_i=0; slot_i<SLOTS; slot_i++){
                        if (least_recently_used[slot_i]<min){
                            min = least_recently_used[slot_i];
                        }
                    }
                    least_recently_used_min = min;
                    //replace any slot with the least_recently_used_score;
                    for (int slot_i=0; slot_i<SLOTS; slot_i++){
                        //std::cout << least_recently_used[slot_i] << least_recently_used_min << "\n";
                        if (least_recently_used[slot_i]==least_recently_used_min){
                            //set valid bit
                            cache[slot_i][0] = 1;
                            //copy data to cache
                            for (int char_i=1; char_i<(CACHE_LINE+1); char_i++){
                                cache[slot_i][char_i] = address[input_i][char_i-1];
                            }
                            std::cout << "...input tag: " << tag << "\n";
                            std::cout << "...contents of slot_i: "<<slot_i<<" evicted.\n";
                            std::cout << "...data copied to cache at slot_i: "<<slot_i<<".\n";
                            std::cout << "...cache["<<slot_i<<"] : ";
                            for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                                std::cout << cache[slot_i][char_i];
                            }
                            std::cout << "\n";
                            //update least_recently_used score for slot
                            least_recently_used[slot_i] = least_recently_used[slot_i] + 1;
                            break;
                        }
                    }
                }
            }
            //for direct mapped cache
            else if (cache_type==2){
                //store at cache[slot_dm]
                //set valid bit
                cache[slot_dm][0] = 1;
                //copy data to cache
                for (int char_i=1; char_i<(CACHE_LINE+1); char_i++){
                    cache[slot_dm][char_i] = address[input_i][char_i-1];
                }
                std::cout << "...input slot: " << slot << "(" << slot_dm << ")\n";
                std::cout << "...data copied to cache at slot_i: "<<slot_dm<<".\n";
                std::cout << "...cache["<<slot_dm<<"] : ";
                for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                    std::cout << cache[slot_dm][char_i];
                }
                std::cout << "\n";
                //update least_recently_used score for slot
                least_recently_used[slot_dm] = least_recently_used[slot_dm] + 1;
            }
            //for set associative
            else if (cache_type==3){
                //find lowest least_recently_used score among the slots in the current set
                int min = least_recently_used[set_sa]; //assume first slot (second slot = 2*set_sa) of the current set is the smallest least_recently_used score and then update accordingly using the for-loop below
                std::cout << "...least_recently_used scores: ";
                for (int slot_i=0; slot_i<SLOTS; slot_i++){
                    if (set_associative_set_index[slot_i]==set_sa){
                        std::cout << "slot_i["<<slot_i<<"]="<<least_recently_used[slot_i]<<"; ";
                        if (least_recently_used[slot_i]<min){
                            min = least_recently_used[slot_i];
                        }
                    }
                }
                std::cout << "\n";
                least_recently_used_min = min;
                //std::cout << "...least_recently_used score: " << min << ".\n";
                //replace any slot of the current set with the least_recently_used_score;
                for (int slot_i=0; slot_i<SLOTS; slot_i++){
                    //std::cout << least_recently_used[slot_i] << least_recently_used_min << "\n";
                    if ((set_associative_set_index[slot_i]==set_sa)&&(least_recently_used[slot_i]==least_recently_used_min)){
                        //set valid bit
                        cache[slot_i][0] = 1;
                        //copy data to cache
                        for (int char_i=1; char_i<(CACHE_LINE+1); char_i++){
                            cache[slot_i][char_i] = address[input_i][char_i-1];
                        }
                        std::cout << "...input set: " << set << "(" << set_sa << ")\n";
                        std::cout << "...data copied to cache at slot_i: "<<slot_i<<".\n";
                        std::cout << "...cache["<<slot_i<<"] : ";
                        for (int char_i=1; char_i<CACHE_LINE+1; char_i++){
                            std::cout << cache[slot_i][char_i];
                        }
                        std::cout << "\n";
                        //update least_recently_used score for slot
                        least_recently_used[slot_i] = least_recently_used[slot_i] + 1;
                        break;
                    }
                }
            }
        }
        
    }
}

int main(int argc, const char * argv[]) {
    // insert code here...
    int type;
    type = choose_cache_type();
    initialize_input();
    //show_array_contents(address);
    retrieve_cache_data(type);
    return 0;
}
