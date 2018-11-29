#include <math.h>
#include <mex.h>
#include <vector>
#include <stdlib.h>

using namespace std;
#ifndef M_PI
#define M_PI 3.1415926535897932384626433
#endif


void mysift(double *im, double *desc, int height,int width)
{
  double sigma=0.8;                             //��˹��ƽ������
  int size=4*ceil(sigma)+1;                     //��˹�˴�С

  vector<vector<double> > g(size,size);         //�����˹��
  vector<vector<double> > gx(size,size);        //�����˹��x�����ݶ�
  vector<vector<double> > gy(size,size);        //�����˹��y�����ݶ�
  //������˹��
  int r=(size-1)/2;
  for(int i=0;i<size;i++)
	for(int j=0;j<size;j++)
	  g[i][j] = exp(-(double)( (i-r)*(i-r)+(j-r)*(j-r) )/(2*sigma*sigma) )/(2*M_PI*sigma*sigma);
  //����ˮƽ�����ݶ�
  for(int j=0;j<size;j++)
  {
     if(j==0)
	 {
	    for(int i=0;i<size;i++)
		{
		  gx[i][j] = g[i][j+1]-g[i][j];
		}
	 }
	 else
	 if (j==size-1)
	 {
	    for(int i=0;i<size;i++)
		{
		   gx[i][j] = g[i][j]-g[i][j-1];
		}
	 }
	 else
	 {
		for(int i=0;i<size;i++)
		{
		  gx[i][j] = (g[i][j+1]-g[i][j-1])*0.5;
		}
	 
	 }
  }

  double sum_gx=0;
  for(int i=0;i<size;i++)
	 for(int j=0;j<size;j++)
        sum_gx += abs(gx[i][j]);
  for(int i=0;i<size;i++)
	for(int j=0;j<size;j++)
		gx[i][j] = 2*gx[i][j]/sum_gx;
  //���㴹ֱ�����ݶ�
  for(int i=0;i<size;i++)
  {
     if(i==0)
	 {
	    for(int j=0;j<size;j++)
		{
		  gy[i][j] = g[i+1][j]-g[i][j];
		}
	 }
	 else
	 if (i==size-1)
	 {
	    for(int j=0;j<size;j++)
		{
		  gy[i][j] = g[i][j]-g[i-1][j];
		}
	 }
	 else
	 {
		for(int j=0;j<size;j++)
		{
		  gy[i][j] = (g[i+1][j]-g[i-1][j])*0.5;
		}
	 
	 }
  }

  double sum_gy=0;
  for(int i=0;i<size;i++)
	for(int j=0;j<size;j++)
        sum_gy += abs(gy[i][j]);
  for(int i=0;i<size;i++)
	for(int j=0;j<size;j++)
		gy[i][j] = 2*gy[i][j]/sum_gx;
  //�ֱ����ͼ��ˮƽ�ʹ�ֱ������ݶ�
  int edge_xsize = (size-1)/2;           //��ӵı�Եx��С 
  int edge_ysize = (size-1)/2;           //��ӵı�Եy��С
  int imc_xsize = height+2*edge_xsize;      //�м�ͼ��im��x��С
  int imc_ysize = width +2*edge_ysize;      //�м�ͼ��im��x��С

  vector<vector<double> > gtx(size,size);             //������ת180�Ⱥ�ĸ�˹��
  vector<vector<double> > gty(size,size);             //������ת180�Ⱥ�ĸ�˹��
  vector<vector<double> > imc(imc_xsize,imc_ysize);	 //�����м�ͼ��
  vector<vector<double> > imdx(height,width);	         //����ͼ��im��x��������Ľ��
  vector<vector<double> > imdy(height,width);	         //����ͼ��im��y��������Ľ��
  //��ԭͼ��im�ڱ߽����0����tmp������
  for(int i=0;i<edge_xsize;i++)
	 for(int j=0;j<width+2*edge_ysize;j++)
		  imc[i][j]=0.0;
  for(int i=edge_xsize;i<height+edge_xsize;i++)
  {
	  for(int j=0;j<edge_ysize;j++)
		  imc[i][j]=0.0;
	  for(int j=edge_ysize;j<width+edge_ysize;j++)
		  imc[i][j]=im[i-edge_xsize+(j-edge_ysize)*height];  //im[(i-edge_xsize)*width+j-edge_ysize];
	  for(int j=width+edge_ysize;j<width+2*edge_ysize;j++)
		  imc[i][j]=0.0;
  }
  for(int i=height+edge_xsize;i<height+2*edge_xsize;i++)
	 for(int j=0;j<width+2*edge_ysize;j++)
		  imc[i][j]=0.0;

  //�����gx,gy��ת180�ȣ��ֱ���gtx,gty������
  for(int i=0;i<size;i++)
	 for(int j=0;j<size;j++)
      { 
        gtx[i][j]=-1.0*gx[size-i-1][size-j-1]; 
        gty[i][j]=-1.0*gy[size-i-1][size-j-1]; 
      }
  //tmp������gtx,gty��ˣ��ֱ𷵻ؽ��Ix,Iy
  double sum_x;             //�����м���
  double sum_y;	  
  for(int i=0;i<height;i++)
    for(int j=0;j<width;j++)
    {
	   sum_x=0.0; sum_y=0.0;
	   for(int ii=0;ii<size;ii++)
	   {
		  for(int jj=0;jj<size;jj++)
		  {   
				sum_x += imc[i+ii][j+jj]*gtx[ii][jj];
                sum_y += imc[i+ii][j+jj]*gty[ii][jj];
		   }
		}
      imdx[i][j]=sum_x;
	  imdy[i][j]=sum_y;
    }
  vector<vector<double> > mag(height,width);	
  vector<vector<double> > gradient_x(height,width);	
  vector<vector<double> > gradient_y(height,width);	
  for(int i=0;i<height;i++)
    for(int j=0;j<height;j++)
    {
		mag[i][j] = sqrt(imdx[i][j]*imdx[i][j]+imdy[i][j]*imdy[i][j]);
        if (mag[i][j]<0.00001)
        {
            gradient_x[i][j]=0; gradient_y[i][j]=1;
        }
        else
        {
	        gradient_x[i][j] = imdx[i][j]/mag[i][j];
			gradient_y[i][j] = imdy[i][j]/mag[i][j];
        }
    }
  int nBins=8;
  int alpha=9;
  vector<vector<vector<double> > > imband(width,vector<vector<double> >(height,vector<double>(nBins) ));
  double theta = M_PI*2/nBins;
  double _cos,_sin, temp;
  for(int k = 0;k<nBins;k++)
  {
	_sin    = sin(theta*k);
	_cos   =  cos(theta*k);
	for(int i = 0;i<height; i++)
       for(int j=0;j<width;j++) 
	  {
		temp = __max(gradient_x[i][j]*_cos + gradient_y[i][j]*_sin,0);
		if(alpha>1)
		     temp = pow(temp,alpha);
		imband[i][j][k] = temp*mag[i][j]; 
	  }
  }
  //����dense sift����
    float sample_x[4]={-0.75,-0.25,0.25,0.75};
    float sample_y[4]={-0.75,-0.25,0.25,0.75};
    int x,y,xh,yh,ix,iy;
    double cx,cy;
    double dx,dy;
    double sample_x_t[4],sample_y_t[4];
    double sample_res;
    double wx,wy,w;
    double tmp;
    int m,c,t;
    int rr=16,siftdim=128, patchsize=32, stepSize=32, cellsize=4, num_samples = 16;
    vector<double> imsift(siftdim,1);
	for(int i=0;i<1;i++)
		for(int j =0;j<1;j++)
		{
             y = __min(__max(i*stepSize,0),height-1);
		     x = __min(__max(j*stepSize,0),width-1);
             cx = x + rr - 0.5;
             cy = y + rr - 0.5;
             for(int k=0;k<cellsize;k++)
             {
                sample_x_t[k] = sample_x[k] * rr + cx;
                sample_y_t[k] = sample_y[k] * rr + cy;
             }
             sample_res = sample_y_t[2] - sample_y_t[1];
             xh = x + patchsize ;
             yh = y + patchsize ;
          for(int b=0;b<nBins;b++)  
          {   
            for(int k1=0;k1<cellsize;k1++)
           {   
             for(int k2=0;k2<cellsize;k2++)
             {
                tmp=0;
                for(int ii=x;ii<xh;ii++)
                { 
                   for(int jj=y;jj<yh;jj++)
                  {
                      ix=ii % patchsize;
                      iy=jj % patchsize;
                      dx=abs(ix-sample_x_t[k1]);
                      dy=abs(iy-sample_y_t[k2]);
                      wx = dx/sample_res;
                      wx = (1 - wx) * (wx <= 1?1:0);
                      wy = dy/sample_res;
                      wy = (1 - wy) * (wy <= 1?1:0);
                      w=wx*wy;
                      tmp += w*imband[ii-y][jj-x][b];
                   }
                }
                imsift[8*k1+32*k2+b]=tmp;
               
             }
            }
            
           }   
        }
     double rm=0;
	 for(int i=0;i<siftdim;i++)
			rm += imsift[i]*imsift[i];
     rm=sqrt(rm);
	   // normalize the SIFT descriptor +(y*width+x)*nBins
        if (rm < 0.00001)
        {
           for(int k=0;k<siftdim;k++)
                 desc[k] = 0.0; 
        }
        else
        {
			  for(int k = 0;k<siftdim;k++)
              {
                  temp = imsift[k]/rm;
                  desc[k] = (temp>0.2)?0.2:temp;
               }
              temp=0;
              for(int k=0;k<siftdim;k++)
                  temp += desc[k]*desc[k];
              for(int k=0;k<siftdim;k++)
                  desc[k] = desc[k]/sqrt(temp); 
         }
    

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
   //����ͼ�����    
  double *im;   
  int height,width;
  im = mxGetPr(prhs[0]);   
  height = mxGetM(prhs[0]);
  width  = mxGetN(prhs[0]);
  if (height!=width)  printf("im.height should be equal to im.width \n");
  //�����������
  int siftdim=128;
  plhs[0] = mxCreateDoubleMatrix(siftdim, 1, mxREAL);
  double *desc = mxGetPr(plhs[0]);
  mysift(im, desc, height, width);

}    
 

