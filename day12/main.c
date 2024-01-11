#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define UINT unsigned int

char *p_pattern;
UINT nchars;
UINT *p_counts;
UINT count_idx;
UINT ncounts;

UINT depth = 1;

UINT line = 1;

size_t total = 0;
size_t cur_solns = 0;

//#define DEBUG
#ifdef DEBUG
#define DPF printf
#else
#define DPF(...)
#endif

void
pprint(char *ppat, UINT pos)
{
    DPF("\t\t%s\n", ppat);
    DPF("\t\t");

    for (int i=0; i<nchars; ++i)
    {
        DPF("%d", i % 10);
    }
    DPF("\n");
    DPF("\t\t");
    for (int i=0; i<pos; ++i)
    {
        DPF(" ");
    }
    DPF("^\n");

}

int
build_at(UINT start, UINT goal, char *ppat, UINT *stop)
{
    char c;
    UINT i;
    UINT tally;
    int found;

    i = start;
    tally = 0;
    found = 0;

    DPF("build_at(start=%zu, goal=%d, ppat='%s')\n", start, goal, ppat);
    while (1)
    {
        DPF(" Considering: (current count=%d)\n", tally);
        pprint(ppat, i);
        DPF(" State on location %zu:  ", i);
        if (tally != goal)
        {
            if (i == nchars)
            {
                DPF("Out of data\n");
                break;
            }
            else
            {
                DPF("Building\n");
            }
        }
        else
        {
            DPF("found count, ");
            if (i >= nchars)
            {
                DPF("end of string, valid\n");
                found = 1;
            }
            else if (ppat[i] == '#')
            {
                DPF("but cur char is #, invalid\n");
            }
            else
            {
                DPF("valid\n");
                found = 1;
            }
            break;
        }

        c = ppat[i];

        if (c == '.')
        {
            break;
        }
        else if (c == '?')
        {
            if (i >= nchars)
            {
                printf("WHOA!!!!!!!!!!!!!!!!!!!!!!! %d\n", __LINE__);
            }
            ppat[i] = '#';
            ++tally; 
        }
        else if (c == '#')
        {
            ++tally;
        }
        else
        {
            printf("BAD LINE\n");
            break;
        }
        ++i;
    }
    *stop = i;
    return found;
}

void
chase(UINT start, UINT count_idx, char *ppat)
{
    char c;
    UINT i;
    UINT j;
    UINT stop;
    UINT goal;
    int found;
    char *copy;

    copy = (char *)malloc(nchars + 1);
    memcpy(copy, ppat, nchars + 1);

    DPF("chase(start=%zu, count_idx=%zu, '%s' [%zu]) DEPTH %zu\n",
        start, count_idx, copy, nchars, depth);

    i = start;
    goal = p_counts[count_idx];

    for (i = start; i < nchars; ++i)
    {
        DPF(" chase loop position i=%zu\n", i);
        if (i > 0 && copy[i - 1] == '#')
        {
            DPF(" * previous char is a '#', cannot build, exit chase\n");
            break;
        }
        /* Stepping over leading '?', set them to '.' for visibility */
        for (j = 0; j < i; ++j)
        {
            if (copy[j] == '?')
            {
                if (j >= nchars)
                {
                    printf("WHOA!!!!!!!!!!!!!!!!!!!!!!! %d\n", __LINE__);
                }
                copy[j] = '.';
            }
        }
        while (copy[i] == '.' && i < nchars)
        {
            ++i;
        }
        found = build_at(i, goal, copy, &stop);
        if (found)
        {
            if (count_idx < (ncounts - 1))
            {
                ++depth;
                chase(stop + 1, count_idx + 1, copy);
                memcpy(copy, ppat, nchars);
                --depth;
                DPF("  return to chase depth %zu (goal=%d) : %s\n", depth, goal, copy);
            }
            else
            {
                int fail = 0;
                DPF("  Checking for trailing # at %zu...\n", stop);
                for (j = stop; j < nchars; ++j)
                {
                    if (copy[j] == '#')
                    {
                        DPF("   Failed on trailing #\n");
                        fail = 1;
                    }
                }
                if (!fail)
                {
                    ++cur_solns;
                    for (j = 0; j < nchars; ++j)
                    {
                        if (copy[j] == '?')
                        {
                            copy[j] = '.';
                        }
                    }
                    //printf("OK %s (restoring for next iteration)\n", copy);
                }
                memcpy(copy, ppat, nchars);
            }
        }
        else
        {
            DPF(" nothing found, restoring pattern to %s\n", ppat);
            memcpy(copy, ppat, nchars);
        }
    }
    free(copy);
}

int
step1(char *linebuf)
{
    char *counts;
    char *count;

    p_pattern = strtok(linebuf, " ");
    if (!p_pattern)
    {
        DPF("Failed to split: '%s'\n", linebuf);
        return 1;
    }
    nchars = strlen(p_pattern);
    counts = strtok(NULL, " ");
    DPF("Parts '%s' [%zu] -> '%s'\n\n", p_pattern, nchars, counts);

    ncounts = 0;
    for (UINT i=0; i<strlen(counts); ++i)
    {
        if (counts[i] == ',')
        {
            ++ncounts;
        }
    }
    ++ncounts;

    p_counts = (UINT *)malloc(ncounts * sizeof(unsigned int));

    if (!p_counts)
    {
        DPF("Failed to malloc space for the counts\n");
        return 1;
    }
    
    UINT i = 0;
    count = strtok(counts, ",");
    do
    {
        p_counts[i] = atoi(count);
        ++i;
        count = strtok(NULL, ",");
    } while (count);

    count_idx = 0;

    cur_solns = 0;
    chase(0, count_idx, p_pattern);
    total += cur_solns;
    printf("%04d RESULTS : %s = %zu\n", line, p_pattern, cur_solns);
    ++line;
    return 0;
}

int
main(int argc, char *argv[])
{
    FILE *fp = NULL;
    char *linebuf = NULL;
    size_t linecap = 0;
    UINT linelen = 0;

    if (argc < 1)
    {
        DPF("Specify the filename\n");
        return -1;
    }
    fp = fopen(argv[1], "r");
    if (!fp)
    {
        DPF("Failed to open file\n");
        return -1;
    }

    while ((linelen = getline(&linebuf, &linecap, fp)) > 0)
    {
        linebuf[strlen(linebuf) - 1] = 0;
        DPF("\n----START----\n\n");
        if (linebuf[0] != '/')
        {
            if (step1(linebuf))
            {
                break;
            }
        }
    }
    free(linebuf);

    fclose(fp);

    printf("RESULTS TOTAL %zu\n", total);
    DPF("\n----DONE----\n\n");
    return 0;
}

/*

RESULTS TOTAL 7163
./a.out input.dat  0.01s user 0.00s system 76% cpu 0.014 total

RESULTS TOTAL 398242
./a.out input2.dat  0.33s user 0.00s system 98% cpu 0.336 total

RESULTS TOTAL 20778962
./a.out input3.dat  163.44s user 0.02s system 99% cpu 2:43.68 total
*/