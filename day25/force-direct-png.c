#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#define GFX
#ifdef GFX
#include "plot.h"
#endif

#define DRAWEDGES

#define XMAX 1000u
#define YMAX 1000u
#if 1
#define SCALE           0.001
#define REPULSION_SELF (-3 * SCALE)
#define REPULSION_EDGE (-4000 * SCALE)
#define ATTRACTION     (1000 * SCALE)
#endif

#if 0
#define SCALE           0.001
#define REPULSION_SELF (-30 * SCALE)
#define REPULSION_EDGE (-40000 * SCALE)
#define ATTRACTION     (1000 * SCALE)
#endif

typedef struct _element
{
    float px;
    float py;
    /* Used during position update */
    float fx;
    float fy;
} element_t;

element_t *set;
size_t g_num_nodes = 0;
int *g_edges;


void
initscene(void)
{
    for (int i=0; i<g_num_nodes; ++i)
    {
        set[i].px = ((float)rand() / RAND_MAX - 0.5) * XMAX / 4.0f + XMAX / 2.0f;
        set[i].py = ((float)rand() / RAND_MAX - 0.5) * YMAX / 4.0f + YMAX / 2.0f;
    }
}

float edge = 0.0f;

void
sum_forces(void)
{
    float dx, dy, d;
    float ix, iy, force;
    int i, j;

    for (i=0; i<g_num_nodes; ++i)
    {
        set[i].fx = 0;
        set[i].fy = 0;

        for (j=0; j<g_num_nodes; ++j)
        {
            if (i != j)
            {
                dx = set[j].px - set[i].px;
                dy = set[j].py - set[i].py;
                d = sqrt(dx * dx + dy * dy);
                if (d != 0.0f)
                {
                    force = REPULSION_SELF / d;
                    ix = force * dx;
                    iy = force * dy;
                    set[i].fx += ix;
                    set[i].fy += iy;
                }
            }
        }

       {
            dx = set[i].px - (XMAX / 2);
            dy = set[i].py - (YMAX / 2);
            d = sqrt(dx * dx + dy * dy);
            if (d != 0.0f)
            {
                force = REPULSION_EDGE / fabs(d-edge);
                ix = force * dx;
                iy = force * dy;
                set[i].fx += ix;
                set[i].fy += iy;
            }
        }

        {
            size_t idx = i * g_num_nodes;
            while (g_edges[idx] != -1)
            {
                j = g_edges[idx];
                dx = set[j].px - set[i].px;
                dy = set[j].py - set[i].py;
                d = sqrt(dx * dx + dy * dy);
                if (d != 0.0f)
                {
                    force = ATTRACTION / d;
                    ix = force * dx;
                    iy = force * dy;
                    set[i].fx += ix;
                    set[i].fy += iy;
                }
                ++idx;
            }
        }
    }

    for (int i=0; i<g_num_nodes; ++i)
    {
        set[i].px += set[i].fx;
        set[i].py += set[i].fy;
    }
}


void
render(void)
{
    static unsigned frames = 0;
#ifdef GFX
#endif
    while (1)
    {
        sum_forces();
#ifdef GFX
        int handle;
        char buf[80];


        sprintf(buf, "%dx%d", XMAX, YMAX);



        pl_parampl("BITMAPSIZE", (void*)buf);
        pl_parampl("VANISH_ON_DELETE", (void*)"yes");
        pl_parampl("USE_DOUBLE_BUFFERING", (void*)"yes");

        sprintf(buf, "img-%03d.gif", frames + 1);
        FILE *fp = fopen(buf, "wb");
        if((handle = pl_newpl("gif", NULL, fp, NULL)) < 0u)
        {
            printf("Failed to initalize plotter (%d)\n", handle);
            return;
        }

        pl_selectpl(handle);
        if (pl_openpl() < 0u)
        {
            printf("Failed to open plotter\n");
            return;
        }

        pl_space(0u, 0u, XMAX - 1u, YMAX - 1u);
        pl_bgcolorname("black");
        pl_pencolorname("white");
        pl_flinewidth(0.25);

        pl_erase();
        for (int i=0; i<g_num_nodes; ++i)
        {
            pl_circle(set[i].px, set[i].py, 2);
            {
                int idx = i * g_num_nodes;
                #ifdef DRAWEDGES
                while (g_edges[idx] != -1)
                {
                    int j = g_edges[idx];
                    pl_fline(set[i].px, set[i].py, set[j].px, set[j].py);
                    ++idx;
                }
                #endif
            }
        }


        pl_closepl();
        pl_selectpl(0);
        pl_deletepl(handle);

        fclose(fp);
        printf("Wrote frame %d\n", frames);
        ++frames;
        if (frames % 100 == 0)
        {
            printf("%u frames\n", frames);
        }
        if (frames == 300)
        {
            break;
        }
#endif
    }
}

void
add_edge(unsigned node_a, unsigned node_b)
{
    size_t base = node_a * g_num_nodes;
    while (g_edges[base] != -1)
    {
        ++base;
    }
    g_edges[base] = node_b;
}

int
main(int argc, char *argv[])
{
    int handle;
    char buf[80];
    char *linebuf;
    size_t n;
    FILE *fp;

    if (argc < 2)
    {
        printf("Please specify the edge file\n");
        return -1;
    }

    fp = fopen(argv[1], "r");

    if (!fp)
    {
        printf("Failed to open file '%s'\n", argv[1]);
    }

    n = 40;
    linebuf = (char *)malloc(n);

    getline(&linebuf, &n, fp);
    g_num_nodes = (size_t)atoi(linebuf + 1u);
    printf("# nodes = %ld\n", g_num_nodes);
    
    set = (element_t *)malloc(g_num_nodes * sizeof(element_t));

    // wasteful but easier
    size_t csize = g_num_nodes * g_num_nodes * sizeof(int);
    printf("csize=%ld\n", csize);
    g_edges = (int *)malloc(csize);
    for (size_t i=0; i<g_num_nodes * g_num_nodes; ++i)
    {
        g_edges[i] = -1;
    }
    while (!feof(fp))
    {
        getline(&linebuf, &n, fp);
        char *tok = strtok(linebuf, " \n");
        if (!tok)
        {
            // eh, i forget getline issues
            break;
        }
        int parent = atoi(tok);
        tok = strtok(NULL, " \n");
        int child = atoi(tok);
        add_edge(parent, child);
        add_edge(child, parent);
    }
    printf("Done\n");
    fclose(fp);
    free(linebuf);

    // Print a check line
    printf("Connections to node 0: ");
    size_t index = 0 * g_num_nodes;
    while (g_edges[index] != -1)
    {
        printf("%u ", g_edges[index]);
        ++index;
    }
    printf("\n");

    edge = sqrt(XMAX*XMAX + YMAX*YMAX);

    srand(0);
    printf("Press ctrl-c to exit...\n");

    initscene();
    render();

    for (int i=0; i<g_num_nodes; ++i)
    {
        {
            int idx = i * g_num_nodes;
            while (g_edges[idx] != -1)
            {
                int j = g_edges[idx];
                float dx = set[i].px - set[j].px;
                float dy = set[i].py - set[j].py;
                float d = sqrt(dx * dx + dy * dy);
                printf("Distance between node %d and %d = %f\n", i, j, d);
                ++idx;
            }
        }
    }

    return 0;
}