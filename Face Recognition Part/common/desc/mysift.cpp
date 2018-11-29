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
  double sigma=0.8;                             //高斯核平滑参数
  int size=4*ceil(sigma)+1;                     //高斯核大小

  vector<vector<double> > g(size,size);         //保存高斯核
  vector<vector<double> > gx(size,size);        //保存高斯核x方向梯度
  vector<vector<double> > gy(size,size);        //保存高斯核y方向梯度
  //产生高斯核
  int r=(size-1)/2;
  for(int i=0;i<size;i++)
	for(int j=0;j<size;j++)
	  g[i][j] = exp(-(double)( (i-r)*(i-r)+(j-r)*(j-r) )/(2*sigma*sigma) )/(2*M_PI*sigma*sigma);
  //计算水平方向梯度
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
  //计算垂直方向梯度
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
  //分别计算图像水平和垂直方向的梯度
  int edge_xsize = (size-1)/2;           //添加的边缘x大小 
  int edge_ysize = (size-1)/2;           //添加的边缘y大小
  int imc_xsize = height+2*edge_xsize;      //中间图像im的x大小
  int imc_ysize = width +2*edge_ysize;      //中间图像im的x大小

  vector<vector<double> > gtx(size,size);             //保存旋转180度后的高斯核
  vector<vector<double> > gty(size,size);             //保存旋转180度后的高斯核
  vector<vector<double> > imc(imc_xsize,imc_ysize);	 //保存中间图像
  vector<vector<double> > imdx(height,width);	         //保存图像im在x方向卷积后的结果
  vector<vector<double> > imdy(height,width);	         //保存图像im在y方向卷积后的结果
  //给原图像im在边界添加0，用tmp保存结果
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

  //卷积核gx,gy旋转180度，分别用gtx,gty保存结果
  for(int i=0;i<size;i++)
	 for(int j=0;j<size;j++)
      { 
        gtx[i][j]=-1.0*gx[size-i-1][size-j-1]; 
        gty[i][j]=-1.0*gy[size-i-1][size-j-1]; 
      }
  //tmp与卷积核gtx,gty相乘，分别返回结果Ix,Iy
  double sum_x;             //保存中间结果
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
  //计算dense sift特征
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
   //输入图像参数    
  double *im;   
  int height,width;
  im = mxGetPr(prhs[0]);   
  height = mxGetM(prhs[0]);
  width  = mxGetN(prhs[0]);
  if (height!=width)  printf("im.height should be equal to im.width \n");
  //输出特征参数
  int siftdim=128;
  plhs[0] = mxCreateDoubleMatrix(siftdim, 1, mxREAL);
  double *desc = mxGetPr(plhs[0]);
  mysift(im, desc, height, width);

}    
 

