#include<stdio.h>

main(int argc,char **argv){
FILE *fin, *fout;
int c;

if (argc < 3){
  fprintf(stderr,"Usage: hex2ascii <HEX file> <ASCII file>\n");
  exit(1);
}
  /* Open the files */
  if((fin=fopen(argv[1],"rb"))==NULL){
    printf("Could not open %s\n",argv[1]);
    exit(1);
  }

  if((fout=fopen(argv[2],"wb"))==NULL){
    printf("Could not open %s\n",argv[2]);
    exit(1);
  }

  /* Convert the input file to binary */
  while(fscanf(fin,"%02x",&c)!=EOF)
    fputc(c,fout);

  /* Close the files */
  fclose(fin);
  fclose(fout);
  return(0);
}
