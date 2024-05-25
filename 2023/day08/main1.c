#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned int hash_l[28*28*28];
unsigned int hash_r[28*28*28];
unsigned int starts[1000];

unsigned int
encode_node(char node[])
{
    return
          (((node[0] - 'A') + 1) * 27 * 27)
        + (((node[1] - 'A') + 1) * 27)
        + (((node[2] - 'A') + 1));
}

void
decode_node(unsigned int encoded, char result[4])
{
    unsigned int upper = encoded / (27 * 27);
    upper += 'A' - 1;
    encoded = encoded - ((upper - 'A' + 1) * 27 * 27);
    
    unsigned int middle = encoded / 27;
    middle += 'A' - 1;
    encoded = encoded - ((middle - 'A' + 1) * 27);

    unsigned int lower = encoded;
    lower += 'A' - 1;

    result[2] = (char)lower;
    result[1] = (char)middle;
    result[0] = (char)upper;
    result[3] = 0;
}

int
main(int argc, char *argv[])
{
    FILE *pin;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    char *dir = NULL;
    char parent[20];
    char left[20];
    char right[20];
    char dummy[20];

    int x;

    unsigned int foo;
    

    foo = encode_node("PJT");
    decode_node(foo, parent);
    printf("PJT = %u = %s\n", foo, parent);

    memset(starts, 1000, sizeof(unsigned int));

    if (argc < 2)
    {
        printf("Please specify a filename\n");
        return -1;
    }
    pin = fopen(argv[1], "r");
    if (NULL == pin)
    {
        printf("Failed to open file %s\n", argv[1]);
        return -1;
    }

    // directions
    read = getline(&line, &len, pin);
    dir = (char *)malloc(len);
    memcpy(dir, line, strlen(line));
    dir[strlen(dir) - 1] = 0;
    printf("Dirs: %s\n", dir);
    read = getline(&line, &len, pin);
    
    size_t start = 0;
    unsigned int pkey, lkey, rkey;
    while ((read = getline(&line, &len, pin)) != -1) {
        printf("Got '%s'\n", line);
        x = sscanf(line, "%s %*[=] %*[(]%s %s%*[)]\n", parent, left, right);
        // wtf is wrong with my sscanf string?
        left[3] = 0;
        right[3] = 0;
        pkey = encode_node(parent);
        lkey = encode_node(left);
        rkey = encode_node(right);
        hash_l[pkey] = lkey;
        hash_r[pkey] = rkey;
        //printf("[%d]:%s:%s:%s\n", x, parent, left, right);
    }
    
    unsigned int cur = encode_node("AAA");
    unsigned int count = 0;
    unsigned int end = encode_node("ZZZ");
            decode_node(end, dummy);
            printf("end %s\n", dummy);
    while (1)
    {
        for (size_t i=0; i<strlen(dir); ++i) {
            ++count;
            decode_node(cur, dummy);
            printf("%d [%c]: %s", count, dir[i], dummy);
            switch (dir[i])
            {
                case 'L':
                    cur = hash_l[cur];
                    break;
                case 'R':
                    cur = hash_r[cur];
                    break;
                default:
                    break;
            }
            decode_node(cur, dummy);
            printf(" -> %s\n", dummy);
            if (cur == end)
            {
                printf("Done (%d)\n", count);
                return -1;
            }
        }
    }
    printf("Done\n");
    fclose(pin);



    return 0;
}