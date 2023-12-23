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
void
print_starts(void)
{
    char dummy[4];
    dummy[3] = 0;
    for (int i=0; starts[i] != 0; ++i)
    {
        decode_node(starts[i], dummy);
        printf("%s ", dummy);
    }
    printf("\n");
}

int
advance_nodes(char dir)
{
    unsigned int end = encode_node("ZZZ");
    char dec[4];
    unsigned int cur;
    int i;
    int zs = 0;
    for (i=0; starts[i] != 0; ++i)
    {
        decode_node(starts[i], dec);
    //    printf("%3d: %s -> ", i, dec);
        switch (dir)
        {
            case 'L':
                starts[i] = hash_l[starts[i]];
                break;
            case 'R':
                starts[i] = hash_r[starts[i]];
                break;
            default:
                break;
        }
        decode_node(starts[i], dec);
  //      printf("%s\n", dec);
        if (dec[2] == 'Z')
        {
            ++zs;
        }
    }
    if (zs == i)
    {
//        printf("i %d vs zs %d\n", i, zs);
        return 1;
    }
    if (zs > 3)
    {
        print_starts();
    }
    return 0;
}

unsigned int
resolve_single(char *dir, unsigned int node)
{
    unsigned int count = 0;
    unsigned int cur = node;
    char dummy[4];
    dummy[3] = 0;
    decode_node(cur, dummy);

    printf("Resolving %s:\n", dummy);
    while (1)
    {
        for (size_t i=0; i<strlen(dir); ++i) {
            ++count;
            decode_node(cur, dummy);
            printf("\t%d [%c]: %s", count, dir[i], dummy);
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
            if (dummy[2] == 'Z')
            {
                printf("Done (%d)\n", count);
                return count;
            }
        }
    }
    return count;
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
        printf("Got %s", line);
        x = sscanf(line, "%s %*[=] %*[(]%s %s%*[)]\n", parent, left, right);
        // wtf is wrong with my sscanf string?
        left[3] = 0;
        right[3] = 0;
        pkey = encode_node(parent);
        lkey = encode_node(left);
        rkey = encode_node(right);
        hash_l[pkey] = lkey;
        hash_r[pkey] = rkey;
        if (parent[2] == 'A')
        {
            starts[start++] = pkey;
        }
        //printf("[%d]:%s:%s:%s\n", x, parent, left, right);
    }

    unsigned long long count = 0;
    /*
    while (1)
    {
        for (size_t i=0; i<strlen(dir); ++i) {
            ++count;
            if (count % 1000000 == 0) 
            {
                printf("Round %llu (%c)\n", count, dir[i]);
            }
            if (advance_nodes(dir[i]) == 1)
            {
                printf("Done %llu\n", count);
                return -1;
            }
        }
    }
    */
    for (int i = 0; starts[i] != 0; ++i)
    {
        decode_node(starts[i], dummy);
        unsigned int x = resolve_single(dir, starts[i]);
        printf("Hops to complete %s: %d\n", dummy, x);
    }
    printf("Done\n");
    fclose(pin);



    return 0;
}