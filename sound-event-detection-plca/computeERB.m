function [X] = computeERB(wavfile)

% Code to compute ERB T/F representation (adapted from E. Vincent)


% Initialize
nbfreq=250;


% Reading WAV file
[x,fs]=wavread(wavfile);
x=resample(x,22050,fs).';
fs = 22050;
[I,T]=size(x);
wlen=2^nextpow2(.02*fs);    %20 ms window length
N=ceil(T/wlen);


% Computing ERBT coefficients and frequency scale
X=zeros(nbfreq,N,I);
for i=1:I,
    [X(:,:,i),f]=erbtm(x(i,:),fs,nbfreq,wlen);
end
X=(sum(X.^2,3)+1e-18).^.5;
fmin=f(1);
fmax=f(nbfreq);
%emin=9.26*log(.00437*fmin+1); emax=9.26*log(.00437*fmax+1);
%e=(0:nbfreq-1)*(emax-emin)/(nbfreq-1)+emin;
%a=.5*(nbfreq-1)/(emax-emin)*9.26*.00437*fs*exp(-e/9.26)-.5;
%alen=2*round(a)+1;
%f=f/fs;



function [X,f]=erbtm(x,fs,F,wlen)

% ERBTM Magnitude ERB Transform using a Hann window.
%
% [X,f]=erbtp(x,fs,F,wlen)
%
% Inputs:
% x: 1 x T vector containing a single-channel signal
% fs: sampling frequency in Hz
% F: number of frequency bins (the ratio between the bandwidth of each bin
% and the frequency difference between successive bins is constant)
% wlen: number of samples per frame (must be a multiple of the largest
% downsampling factor, typically a large power of 2)
%
% Output:
% X: F x N matrix containing the time-frequency magnitude (amplitude) coefficients
% f: F x 1 vector containing the center frequency of each frequency bin

%%% Errors and warnings %%%
if nargin<4, error('Not enough input arguments.'); end
[I,T]=size(x);
if I>1, error('The input signal must be a row vector.'); end
N=ceil(T/wlen);

%%% Computing ERBT coefficients %%%
x=hilbert(x);
X=zeros(F,N);
% Determining minimum and maximum frequency
fmax=.5*fs; fmin=0;
for j=1:100,
    emin=9.26*log(.00437*fmin+1);
    emax=9.26*log(.00437*fmax+1);
    fmin=1.5*(emax-emin)/(F-1)/9.26/.00437*exp(emin/9.26);
    fmax=.5*fs-1.5*(emax-emin)/(F-1)/9.26/.00437*exp(emax/9.26);
    if (fmax < 0) || (fmin > .5*fs), error('The number of frequency bins is too small.'); end
end
% Determining frequency and window length scales
emin=9.26*log(.00437*fmin+1);
emax=9.26*log(.00437*fmax+1);
e=(0:F-1)*(emax-emin)/(F-1)+emin;
f=(exp(e/9.26)-1)/.00437;
a=.5*(F-1)/(emax-emin)*9.26*.00437*fs*exp(-e/9.26)-.5;
% Determining dyadic downsampling bins (for fast computation)
fup=f+1.5*fs./(2*a+1);
subs=-log(2*fup/fs)/log(2);
subs=2.^max(0,floor(min(log2(wlen),subs)));
if (wlen/subs(1) ~= floor(wlen/subs(1))), error(['The number of samples per frame must be a multiple of ' int2str(subs(1)) '.']); end
down=(subs~=[subs(2:end),1]);
for bin=F:-1:1,
    % Dyadic downsampling
    if down(bin),
        x=resample(x,1,2,50);
    end
    % Convolution with a modulated sine window
    hwlen=round(a(bin)/subs(bin));
    win=hanning(2*hwlen+1).'.*exp(2i*pi*f(bin)/fs*subs(bin)*(-hwlen:hwlen));
    band=[fftfilt(win,[x,zeros(1,2*hwlen)]) zeros(1,wlen/subs(bin))];
    % Square-root energy on short time frames
    band=band(hwlen+1:hwlen+N*wlen/subs(bin));
    X(bin,:)=sqrt(sum(reshape(abs(band).^2,wlen/subs(bin),N),1)/(hwlen+1)^2*subs(bin));
end

return;