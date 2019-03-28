/* Test and timing harness program for developing a multichannel
   multikernel convolution (as used in deep learning networks)

   Note there are some simplifications around this implementation,
   in particular with respect to computing the convolution at edge
   pixels of the image.

   Author: David Gregg
   Date:   February 2019

   Version 1.5 : Modified the code so that the input and kernel
                 are tensors of 16-bit integer values

   Version 1.4 : Modified the random generator to reduce the range
                 of generated values;

   Version 1.3 : Fixed which loop variables were being incremented
                 in write_out();
                 Fixed dimensions of output and control_output 
                 matrices in main function

   Version 1.2 : Changed distribution of test data to (hopefully) 
                 eliminate random walk of floating point error;
                 Also introduced checks to restrict kernel-order to
                 a small set of values

   Version 1.1 : Fixed bug in code to create 4d matrix
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <assert.h>
#include <omp.h>
#include <math.h>
#include <stdint.h>
#include <x86intrin.h>

/* the following two definitions of DEBUGGING control whether or not
   debugging information is written out. To put the program into
   debugging mode, uncomment the following line: */
/*#define DEBUGGING(_x) _x */
/* to stop the printing of debugging information, use the following line: */
#define DEBUGGING(_x)

#define MIN(X, Y) (((X) > (Y)) ? (Y) : (X))
#define OPENMP_THRESHHOLD 107374182400
/* write 3d matrix to stdout */
void write_out(int16_t *** a, int dim0, int dim1, int dim2)
{
  int i, j, k;

  for ( i = 0; i < dim0; i++ ) {
    printf("Outer dimension number %d\n", i);
    for ( j = 0; j < dim1; j++ ) {
      for ( k = 0; k < dim2 - 1; k++ ) {
        printf("%d, ", a[i][j][k]);
      }
      // print end of line
      printf("%f\n", a[i][j][dim2-1]);
    }
  }
}


/* create new empty 4d float matrix */
float **** new_empty_4d_matrix_float(int dim0, int dim1, int dim2, int dim3)
{
  float **** result = malloc(dim0 * sizeof(float***));
  float *** mat1 = malloc(dim0 * dim1 * sizeof(float**));
  float ** mat2 = malloc(dim0 * dim1 * dim2 * sizeof(float*));
  float * mat3 = malloc(dim0 * dim1 * dim2 *dim3 * sizeof(float));
  int i, j, k;

  
  for ( i = 0; i < dim0; i++ ) {
    result[i] = &(mat1[i*dim1]);
    for ( j = 0; j < dim1; j++ ) {
      result[i][j] = &(mat2[i*dim1*dim2 + j*dim2]);
      for ( k = 0; k < dim2; k++ ) {
        result[i][j][k] = &(mat3[i*dim1*dim2*dim3+j*dim2*dim3+k*dim3]);
      }
    }
  }

  return result;
}

/* create new empty 3d matrix */
float *** new_empty_3d_matrix_float(int dim0, int dim1, int dim2)
{
  float **** mat4d;
  float *** mat3d;

  // create a 4d matrix with single first dimension
  mat4d = new_empty_4d_matrix_float(1, dim0, dim1, dim2);
  // now throw away out first dimension
  mat3d = mat4d[0];
  free(mat4d);
  return mat3d;
}

/* create new empty 4d int16_t matrix */
int16_t **** new_empty_4d_matrix_int16(int dim0, int dim1, int dim2, int dim3)
{
  int16_t **** result = malloc(dim0 * sizeof(int16_t***));
  int16_t *** mat1 = malloc(dim0 * dim1 * sizeof(int16_t**));
  int16_t ** mat2 = malloc(dim0 * dim1 * dim2 * sizeof(int16_t*));
  int16_t * mat3 = malloc(dim0 * dim1 * dim2 *dim3 * sizeof(int16_t));
  int i, j, k;

  
  for ( i = 0; i < dim0; i++ ) {
    result[i] = &(mat1[i*dim1]);
    for ( j = 0; j < dim1; j++ ) {
      result[i][j] = &(mat2[i*dim1*dim2 + j*dim2]);
      for ( k = 0; k < dim2; k++ ) {
        result[i][j][k] = &(mat3[i*dim1*dim2*dim3+j*dim2*dim3+k*dim3]);
      }
    }
  }

  return result;
}

/* create new empty 3d matrix */
int16_t *** new_empty_3d_matrix_int16(int dim0, int dim1, int dim2)
{
  int16_t **** mat4d;
  int16_t *** mat3d;

  // create a 4d matrix with single first dimension
  mat4d = new_empty_4d_matrix_int16(1, dim0, dim1, dim2);
  // now throw away out first dimension
  mat3d = mat4d[0];
  free(mat4d);
  return mat3d;
}

/* take a copy of the matrix and return in a newly allocated matrix */
int16_t **** copy_4d_matrix(int16_t **** source_matrix, int dim0,
                            int dim1, int dim2, int dim3)
{
  int i, j, k, l;
  int16_t **** result = new_empty_4d_matrix_int16(dim0, dim1, dim2, dim3);

  for ( i = 0; i < dim0; i++ ) {
    for ( j = 0; j < dim1; j++ ) {
      for ( k = 0; k < dim2; k++ ) {
        for ( l = 0; l < dim3; l++ ) {
          result[i][j][k][l] = source_matrix[i][j][k][l];
        }
      }
    }
  }
  return result;
}

/* create a matrix and fill it with random numbers */
int16_t **** gen_random_4d_matrix_int16(int dim0, int dim1, int dim2, int dim3)
{
int16_t **** result;
int i, j, k, l;
struct timeval seedtime;
  int seed;

  result = new_empty_4d_matrix_int16(dim0, dim1, dim2, dim3);

  /* use the microsecond part of the current time as a pseudorandom seed */
  gettimeofday(&seedtime, NULL);
  seed = seedtime.tv_usec;
  srandom(seed);

  /* fill the matrix with random numbers */
  const int range = 1 << 10; // 2^10
  //const int bias = 1 << 16; // 2^16
  int16_t offset = 0.0;
  for ( i = 0; i < dim0; i++ ) {
    for ( j = 0; j < dim1; j++ ) {
      for ( k = 0; k < dim2; k++ ) {
        for ( l = 0; l < dim3; l++ ) {
          // generate uniform random integer with mean of zero
          long long rand = random();
          // now cut down the range and bias the mean to reduce
          // the likelihood of large floating point round-off errors
          int reduced_range = (rand % range);
          result[i][j][k][l] = reduced_range;
        }
      }
    }
  }

  return result;
}

/* create a matrix and fill it with random numbers */
int16_t *** gen_random_3d_matrix_int16(int dim0, int dim1, int dim2)
{
  int16_t **** mat4d;
  int16_t *** mat3d;

  // create a 4d matrix with single first dimension
  mat4d = gen_random_4d_matrix_int16(1, dim0, dim1, dim2);
  // now throw away out first dimension
  mat3d = mat4d[0];
  free(mat4d);
  return mat3d;
}

/* check the sum of absolute differences is within reasonable epsilon */
void check_result(float *** result, float *** control,
                  int dim0, int dim1, int dim2)
{
  int i, j, k;
  double sum_abs_diff = 0.0;
  const double EPSILON = 0.0625;

  //printf("SAD\n");
  
  for ( i = 0; i < dim0; i++ ) {
    for ( j = 0; j < dim1; j++ ) {
      for ( k = 0; k < dim2; k++ ) {
        double diff = fabs(control[i][j][k] - result[i][j][k]);
        assert( diff >= 0.0 );
        sum_abs_diff = sum_abs_diff + diff;
      }
    }
  }

  if ( sum_abs_diff > EPSILON ) {
    fprintf(stderr, "WARNING: sum of absolute differences (%f) > EPSILON (%f)\n",
            sum_abs_diff, EPSILON);
  }
  else {
    printf("COMMENT: sum of absolute differences (%f)  within acceptable range (%f)\n", sum_abs_diff, EPSILON);
  }
}

/* the slow but correct version of matmul written by David */
void multichannel_conv(int16_t *** image, int16_t **** kernels,
		       float *** output, int width, int height,
		       int nchannels, int nkernels, int kernel_order)
{
  int h, w, x, y, c, m;

  for ( m = 0; m < nkernels; m++ ) {
    for ( w = 0; w < width; w++ ) {
      for ( h = 0; h < height; h++ ) {
        double sum = 0.0;
        for ( c = 0; c < nchannels; c++ ) {
          for ( x = 0; x < kernel_order; x++) {
            for ( y = 0; y < kernel_order; y++ ) {
              sum += (double) image[w+x][h+y][c] * (double) kernels[m][c][x][y];
            }
          }
          output[m][w][h] = (float) sum;
        }
      }
    }
  }
}


/* Old image transpose function, used before the vectorization, uses some dynamic loop unrolling */
int16_t *** change_image_dimension_order(int16_t *** image, int nchannels, int width, int height, int kernel_order) {

  //int16_t *** new_image = new_empty_3d_matrix_int16(nchannels, width+kernel_order, height+kernel_order);
  int temp1 = width + kernel_order; 
  int temp2 = height + kernel_order;
  
  int16_t *** new_image = malloc(nchannels * sizeof(int16_t **));
  int16_t ** mat1 = malloc(nchannels * temp1 * sizeof(int16_t *));
  int16_t * mat2 = malloc(nchannels * temp1 * temp2 *sizeof(int16_t));
  size_t i, j, k;
  
  size_t iter = temp2 / 8;
  size_t left = temp2 % 8;

 #pragma omp parallel for private(iter, left, j)
  for(i = 0; i<nchannels; i++) {
    new_image[i] = &(mat1[i*temp1]);
    for( j = 0; iter > 0; iter--) {
      new_image[i][j] = &(mat2[i*temp1*temp2 + j * temp2]);
      new_image[i][j+1] = &(mat2[i*temp1*temp2 + (j+1) * temp2]);
      new_image[i][j+2] = &(mat2[i*temp1*temp2 + (j+2) * temp2]);
      new_image[i][j+3] = &(mat2[i*temp1*temp2 + (j+3) * temp2]);
      new_image[i][j+4] = &(mat2[i*temp1*temp2 + (j+4) * temp2]);
      new_image[i][j+5] = &(mat2[i*temp1*temp2 + (j+5) * temp2]);
      new_image[i][j+6] = &(mat2[i*temp1*temp2 + (j+6) * temp2]);
      new_image[i][j+7] = &(mat2[i*temp1*temp2 + (j+7) * temp2]);
      j+=8;
    }
    switch(left) {
        case 7:
          new_image[i][j+7] = &(mat2[i*temp1*temp2 + (j+7) * temp2]);
        case 6:
          new_image[i][j+6] = &(mat2[i*temp1*temp2 + (j+6) * temp2]);
        case 5:
          new_image[i][j+5] = &(mat2[i*temp1*temp2 + (j+5) * temp2]);
        case 4:
          new_image[i][j+4] = &(mat2[i*temp1*temp2 + (j+4) * temp2]);
        case 3:
          new_image[i][j+3] = &(mat2[i*temp1*temp2 + (j+3) * temp2]);
        case 2:
          new_image[i][j+2] = &(mat2[i*temp1*temp2 + (j+2) * temp2]);
        case 1:
          new_image[i][j+1] = &(mat2[i*temp1*temp2 + (j+1) * temp2]);
    }
  }
  iter = temp2 / 8;
  left = temp2 % 8;

 #pragma omp parallel for collapse(2) private(k, iter, left)
  for(i = 0; i<nchannels; i++) {
    for( j = 0; j<temp1; j++) {
      for( k = 0; iter > 0; iter--) {
        __m128i a = _mm_set_epi16( image[j][k][i], image[j][k+1][i],
                                  image[j][k+2][i], image[j][k+3][i],
                                  image[j][k+4][i], image[j][k+5][i],
                                  image[j][k+6][i], image[j][k+7][i]);
        _mm_store_si128(&new_image[i][j][k], a);   
        k+=8;                               
      }
      switch(left) {
        case 7:
          new_image[i][j][k+7] = image[j][k+7][i];
        case 6:
          new_image[i][j][k+6] = image[j][k+6][i];
        case 5:
          new_image[i][j][k+5] = image[j][k+5][i];
        case 4:
          new_image[i][j][k+4] = image[j][k+4][i];
        case 3:
          new_image[i][j][k+3] = image[j][k+3][i];
        case 2:
          new_image[i][j][k+2] = image[j][k+2][i];
        case 1:
          new_image[i][j][k+1] = image[j][k+1][i];
      }
    }
  }

  // #pragma omp parallel for collapse(3)
  // for(i = 0; i<nchannels; i++) {
  //   for( j = 0; j<temp1; j++) {
  //    for( k = 0; k<temp2; k++) {
  //      new_image[i][j][k] = image[j][k][i];
  //     }
  //   }
  // }    
  return new_image;
}


int16_t **** restrict change_kernel_dimension_order(int16_t **** restrict kernel, int nkernels, int nchannels, int kernel_order) {

  int16_t **** new_kernel = malloc(nkernels * sizeof(int16_t***));
  int16_t *** mat1 = malloc(nkernels * kernel_order * sizeof(int16_t**));
  int16_t ** mat2 = malloc(nkernels * kernel_order * kernel_order * sizeof(int16_t*));
  int16_t * mat3 = malloc(nkernels * kernel_order * kernel_order * nchannels * sizeof(int16_t));
  size_t i, j, k;
 
 for ( i = 0; i < nkernels; i++ ) {
    new_kernel[i] = &(mat1[i*kernel_order]);
    for ( j = 0; j < kernel_order; j++ ) {
      new_kernel[i][j] = &(mat2[i*kernel_order*kernel_order + j*kernel_order]);
      for ( k = 0; k < kernel_order; k++ ) {
        new_kernel[i][j][k] = &(mat3[i*kernel_order*kernel_order*nchannels+j*kernel_order*nchannels+k*nchannels]);
      }
    }
  }
  
  size_t blocksize = 32;



  #pragma omp parallel for schedule(static) collapse(3) if( nchannels * nkernels * kernel_order * kernel_order > 10000000)
  for( size_t i = 0; i<nkernels; i++) {  
    
    for( size_t l1 = 0 ; l1<nchannels; l1+=blocksize) {
      for( size_t j = 0; j<kernel_order; j++) {
        for( size_t k = 0; k<kernel_order; k++) {
          
          	 /* Vectorized matrix transpose with tiling */
          for(size_t l = 0; l<MIN(nchannels-l1, blocksize); l+=8) {
            __m128i a = _mm_set_epi16(kernel[i][l1+l+7][j][k], kernel[i][l1+l+6][j][k],
                                      kernel[i][l1+l+5][j][k], kernel[i][l1+l+4][j][k],
                                      kernel[i][l1+l+3][j][k], kernel[i][l1+l+2][j][k],
                                      kernel[i][l1+l+1][j][k], kernel[i][l1+l][j][k]);
            
            _mm_store_si128(&new_kernel[i][j][k][l1+l], a);
          }        
        }
      }
    }  

  //   for( size_t j = 0; j<kernel_order; j++) {
  //     for( size_t k = 0; k<kernel_order; k++) {
  //       for(size_t l = 0; l<nchannels; l+=8) {
  //         __m128i a = _mm_set_epi16(kernel[i][l+7][j][k], kernel[i][l+6][j][k],
  //                                     kernel[i][l+5][j][k], kernel[i][l+4][j][k],
  //                                     kernel[i][l+3][j][k], kernel[i][l+2][j][k],
  //                                     kernel[i][l+1][j][k], kernel[i][l][j][k]);
  //         _mm_store_si128(&new_kernel[i][j][k][l], a);
          
  //         //new_kernel[i][j][k][l] = kernel[i][l][j][k];
  //       }
  //     }
  //   }
  }    
  return new_kernel;  
}

/* the fast version of matmul written by the team */
inline static void team_conv(int16_t *** restrict image,  int16_t **** restrict kernels, float *** restrict output,
               int width, int height, int nchannels, int nkernels,
               int kernel_order)
{
  kernels = change_kernel_dimension_order(kernels, nkernels, nchannels, kernel_order);
  int h, w, x, y, c, m;
  int threshhold = kernel_order * kernel_order * nchannels * nkernels;
  if( threshhold > 25000000 ) {
   //if(0) {
    printf("1\n");
    #pragma omp parallel for collapse(3) 
      for ( m = 0; m < nkernels; m++ ) {
        for ( w = 0; w < width; w++ ) {
          for ( h = 0; h < height; h++ ) {
              long sum = 0L;
              #pragma omp parallel for collapse(3) reduction(+:sum)
              for ( x = 0; x < kernel_order; x++) {
                for ( y = 0; y < kernel_order; y++ ) {
                  for( c = 0; c < nchannels; c+= 32) {
                    size_t temp1 = c;
                    size_t temp2 = c+8;
                    size_t temp3 = c+16;
                    size_t temp4 = c+24;
                
                    __m128i a1 = _mm_load_si128(&image[w+x][h+y][temp1]);
                    __m128i b1 = _mm_load_si128(&kernels[m][x][y][temp1]);
                    a1 = _mm_madd_epi16(a1, b1);
                
                    __m128i a2 = _mm_load_si128(&image[w+x][h+y][temp2]);
                    __m128i b2 = _mm_load_si128(&kernels[m][x][y][temp2]);
                    a2 = _mm_madd_epi16(a2 , b2);
                
                    __m128i a3 = _mm_load_si128(&image[w+x][h+y][temp3]);
                    __m128i b3 = _mm_load_si128(&kernels[m][x][y][temp3]);
                    a3 = _mm_madd_epi16(a3, b3);     
                    
                    __m128i a4 = _mm_load_si128(&image[w+x][h+y][temp4]);
                    __m128i b4 = _mm_load_si128(&kernels[m][x][y][temp4]);
                    a4 = _mm_madd_epi16(a4, b4);

                    a1 = _mm_add_epi32(a1, a2);
                    a3 = _mm_add_epi32(a3, a4);
                    a1 = _mm_add_epi32(a1, a3);
                    a1 = _mm_hadd_epi32(a1, a1);
                    a1 = _mm_hadd_epi32(a1, a1);
                    sum +=  _mm_extract_epi32(a1, 0);
                  }
                }
              }
              output[m][w][h] = (float) sum;


              /*
__m128i total = _mm_setzero_si128();
              #pragma omp parallel
              {
              	__m128i sum = _mm_setzero_si128();
              #pragma omp  for collapse(3) 
              for ( x = 0; x < kernel_order; x++) {
                for ( y = 0; y < kernel_order; y++ ) {
                  for( c = 0; c < nchannels; c+= 32) {
                    size_t temp1 = c;
                    size_t temp2 = c+8;
                    size_t temp3 = c+16;
                    size_t temp4 = c+24;

                    __m128i a1 = _mm_load_si128(&image[w+x][h+y][temp1]);
                    __m128i b1 = _mm_load_si128(&kernels[m][x][y][temp1]);
                    a1 = _mm_madd_epi16(a1, b1);
                
                    __m128i a2 = _mm_load_si128(&image[w+x][h+y][temp2]);
                    __m128i b2 = _mm_load_si128(&kernels[m][x][y][temp2]);
                    a2 = _mm_madd_epi16(a2 , b2);
                
                    __m128i a3 = _mm_load_si128(&image[w+x][h+y][temp3]);
                    __m128i b3 = _mm_load_si128(&kernels[m][x][y][temp3]);
                    a3 = _mm_madd_epi16(a3, b3);     
                    
                    __m128i a4 = _mm_load_si128(&image[w+x][h+y][temp4]);
                    __m128i b4 = _mm_load_si128(&kernels[m][x][y][temp4]);
                    a4 = _mm_madd_epi16(a4, b4);

                    a1 = _mm_add_epi32(a1, a2);
                    a3 = _mm_add_epi32(a3, a4);
                    a1 = _mm_add_epi32(a1, a3);
                    sum = _mm_add_epi32(a1, sum);
                  }
                }
              }
              #pragma omp critical
          	{
          		total = _mm_add_epi32(total, sum);
          	}
          	}
				total = _mm_hadd_epi32(total, total);
				total = _mm_hadd_epi32(total, total);
              output[m][w][h] = (float) _mm_extract_epi32(total, 0);
          	}
              */
          }
        }
      }    
  }

  // else if(1) {
  else if((width >= 256 && height >= 256 && kernel_order >= 3) || (width >= 64 && height >= 64 && nchannels >= 128)) {  
    printf("2\n");
    #pragma omp parallel for collapse(3)
      for ( m = 0; m < nkernels; m++ ) {
        for ( w = 0; w < width; w++ ) {
          for ( h = 0; h < height; h++ ) {
            long sum = 0L;
              for ( x = 0; x < kernel_order; x++) {
                for ( y = 0; y < kernel_order; y++ ) {
                for ( c = 0; c < nchannels; c+=32 ) {      
                    size_t temp1 = c;
                    size_t temp2 = c+8;
                    size_t temp3 = c+16;
                    size_t temp4 = c+24;
                
                  
                    __m128i a1 = _mm_load_si128(&image[w+x][h+y][temp1]);
                    __m128i b1 = _mm_load_si128(&kernels[m][x][y][temp1]);
                    a1 = _mm_madd_epi16(a1, b1);
                
                    __m128i a2 = _mm_load_si128(&image[w+x][h+y][temp2]);
                    __m128i b2 = _mm_load_si128(&kernels[m][x][y][temp2]);
                    a2 = _mm_madd_epi16(a2 , b2);
                
                    __m128i a3 = _mm_load_si128(&image[w+x][h+y][temp3]);
                    __m128i b3 = _mm_load_si128(&kernels[m][x][y][temp3]);
                    a3 = _mm_madd_epi16(a3, b3);     
                    
                    __m128i a4 = _mm_load_si128(&image[w+x][h+y][temp4]);
                    __m128i b4 = _mm_load_si128(&kernels[m][x][y][temp4]);
                    a4 = _mm_madd_epi16(a4, b4);

                    a1 = _mm_add_epi32(a1, a2);
                    a3 = _mm_add_epi32(a3, a4);
                    a1 = _mm_add_epi32(a1, a3);
                    a1 = _mm_hadd_epi32(a1, a1);
                    a1 = _mm_hadd_epi32(a1, a1);
                    sum +=  _mm_extract_epi32(a1, 0);
                  }
                }
              }   
              output[m][w][h] = (float) sum;
          }    
        }
      }
  }

  else {
    printf("3\n");
    for ( m = 0; m < nkernels; m++ ) {
        for ( w = 0; w < width; w++ ) {
          for ( h = 0; h < height; h++ ) {
              long sum = 0L;
              for ( x = 0; x < kernel_order; x++) {
                for ( y = 0; y < kernel_order; y++ ) {
                for ( c = 0; c < nchannels; c+=32 ) {      
                    size_t temp1 = c;
                    size_t temp2 = c+8;
                    size_t temp3 = c+16;
                    size_t temp4 = c+24;
                
                
                    __m128i a1 = _mm_load_si128(&image[w+x][h+y][temp1]);
                    __m128i b1 = _mm_load_si128(&kernels[m][x][y][temp1]);
                    a1 = _mm_madd_epi16(a1, b1);
                
                    __m128i a2 = _mm_load_si128(&image[w+x][h+y][temp2]);
                    __m128i b2 = _mm_load_si128(&kernels[m][x][y][temp2]);
                    a2 = _mm_madd_epi16(a2 , b2);
                
                    __m128i a3 = _mm_load_si128(&image[w+x][h+y][temp3]);
                    __m128i b3 = _mm_load_si128(&kernels[m][x][y][temp3]);
                    a3 = _mm_madd_epi16(a3, b3);     
                    
                    __m128i a4 = _mm_load_si128(&image[w+x][h+y][temp4]);
                    __m128i b4 = _mm_load_si128(&kernels[m][x][y][temp4]);
                    a4 = _mm_madd_epi16(a4, b4);

                    a1 = _mm_add_epi32(a1, a2);
                    a3 = _mm_add_epi32(a3, a4);
                    a1 = _mm_add_epi32(a1, a3);
                    a1 = _mm_hadd_epi32(a1, a1);
                    a1 = _mm_hadd_epi32(a1, a1);
                    sum +=  _mm_extract_epi32(a1, 0);
                  }
                }
              }
              output[m][w][h] = (float) sum;
          }    
        }
      }
  } 
}

int main(int argc, char ** argv)
{
  //float image[W][H][C];
  //float kernels[M][C][K][K];
  //float output[M][W][H];
  
  int16_t *** image, **** kernels;
  float *** control_output, *** output;
  long long mul_time;
  int width, height, kernel_order, nchannels, nkernels;
  struct timeval start_time;
  struct timeval stop_time;

  if ( argc != 6 ) {
    fprintf(stderr, "Usage: conv-harness <image_width> <image_height> <kernel_order> <number of channels> <number of kernels>\n");
    exit(1);
  }
  else {
    width = atoi(argv[1]);
    height = atoi(argv[2]);
    kernel_order = atoi(argv[3]);
    nchannels = atoi(argv[4]);
    nkernels = atoi(argv[5]);
  }
  switch ( kernel_order ) {
  case 1:
  case 3:
  case 5:
  case 7: break;
  default:
    fprintf(stderr, "FATAL: kernel_order must be 1, 3, 5 or 7, not %d\n",
            kernel_order);
    exit(1);
  }

  /* allocate the matrices */
  image = gen_random_3d_matrix_int16(width+kernel_order, height + kernel_order,
                               nchannels);
  kernels = gen_random_4d_matrix_int16(nkernels, nchannels, kernel_order, kernel_order);
  output = new_empty_3d_matrix_float(nkernels, width, height);
  control_output = new_empty_3d_matrix_float(nkernels, width, height);

  //DEBUGGING(write_out(A, a_dim1, a_dim2));

  gettimeofday(&start_time, NULL);
  /* use a simple multichannel convolution routine to produce control result */
  multichannel_conv(image, kernels, control_output, width,
                    height, nchannels, nkernels, kernel_order);

  gettimeofday(&stop_time, NULL);
  long long mul_time_1 = (stop_time.tv_sec - start_time.tv_sec) * 1000000L +
    (stop_time.tv_usec - start_time.tv_usec);
  /* record starting time of team's code*/
 
  
  
  
  
  /* record starting time of team's code*/
  gettimeofday(&start_time, NULL);

  /* perform student team's multichannel convolution */
  team_conv(image, kernels, output, width,
                    height, nchannels, nkernels, kernel_order);

  /* record finishing time */
  gettimeofday(&stop_time, NULL);
  mul_time = (stop_time.tv_sec - start_time.tv_sec) * 1000000L +
    (stop_time.tv_usec - start_time.tv_usec);
  printf("Team conv time: %lld microseconds\n", mul_time);
  printf("Speed up of %lld\n", mul_time_1 / mul_time);
  DEBUGGING(write_out(output, nkernels, width, height));

  /* now check that the team's multichannel convolution routine
     gives the same answer as the known working version */
  check_result(output, control_output, nkernels, width, height);

  return 0;
}