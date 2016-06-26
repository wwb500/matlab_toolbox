function simpleWriteMatrix(m, fileName)

fid = fopen(fileName, 'w');
fwrite(fid, m, 'double');
fclose(fid);
