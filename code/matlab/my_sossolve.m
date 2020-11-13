function [sos,info] = my_sossolve(sos,options)
% SOSSOLVE --- Solve a sum of squares program.
%
% SOSP = sossolve(SOSP)
%
% SOSP is the SOS program to be solved.
%
% Alternatively, SOSP = sossolve(SOSP,SOLVER_OPT) also defines the solver 
% and/or the solver-specific options respectively by fields
%
% SOLVER_OPT.solver (name of the solver). This can be 'sedumi', 'sdpnal',
% 'sdpnalplus', 'cdsp', 'cdcs', 'sdpt3', 'sdpa'. 
% SOLVER_OPT.params (a structure containing solver-specific parameters)
%
% The default values for solvers is 'SeDuMi' with parameter ALG = 2, which 
% uses the xz-linearization in the corrector and parameter tol =1e-9. See 
% SeDuMi help files or user manual for more detail.
% 
% Using a second output argument such as [SOSP,INFO] = sossolve(SOSP) will
% return in INFO numerous information concerning feasibility  and CPU time
% that is generated by the SDP solver.
%

% This file is part of SOSTOOLS - Sum of Squares Toolbox ver 3.03.
%
% Copyright (C)2002, 2004, 2013, 2016, 2018  A. Papachristodoulou (1), J. Anderson (1),
%                                      G. Valmorbida (2), S. Prajna (3), 
%                                      P. Seiler (4), P. A. Parrilo (5)
% (1) Department of Engineering Science, University of Oxford, Oxford, U.K.
% (2) Laboratoire de Signaux et Systmes, CentraleSupelec, Gif sur Yvette,
%     91192, France
% (3) Control and Dynamical Systems - California Institute of Technology,
%     Pasadena, CA 91125, USA.
% (4) Aerospace and Engineering Mechanics Department, University of
%     Minnesota, Minneapolis, MN 55455-0153, USA.
% (5) Laboratory for Information and Decision Systems, M.I.T.,
%     Massachusetts, MA 02139-4307
%
% Send bug reports and feedback to: sostools@cds.caltech.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%

% 12/25/01 - SP
% 01/05/02 - SP - primal
% 01/07/02 - SP - objective
% aug/13 - JA,GV - CDSP,SDPNAL,SDPA solvers and SOS matrix decomposition
% 06/01/16 - JA - added interface to frlib facial reduction package by 
%                 F Permenter and PP.
% 01/04/18 - AP - Added CDCS and SDPNALplus

if (nargin==1)
   %Default options from old sossolve
   options.solver = 'sedumi';
   options.params.tol = 1e-9;
   options.params.alg = 2; 
elseif ((nargin==2) & ~isnumeric('options') )%2 arguments given,
    if ~isfield(options,'solver')
       options.solver = 'sedumi';
    end
    if ~isfield(options,'params')
        options.params.tol = 1e-9;%default values for SeDuMi
        options.params.alg = 2; 
    end
end


%whenever nargin>=2 options are overwritten
if (nargin==3)
    error('Current SOSTOOLS version does not support call to sossolve with 3 arguments, see manual.');
end;

if ~isempty(sos.solinfo.x)
    error('The SOS program is already solved.');
end;

% Adding slack variables to inequalities
sos.extravar.idx{1} = sos.var.idx{sos.var.num+1};
% SOS variables
I = [find(strcmp(sos.expr.type,'ineq')), find(strcmp(sos.expr.type,'sparse')), find(strcmp(sos.expr.type,'sparsemultipartite'))];
if ~isempty(I)
    sos = addextrasosvar(sos,I);
end;
% SOS variables type II (restricted on interval)
I = find(strcmp(sos.expr.type,'posint'));
if ~isempty(I)
    sos = addextrasosvar2(sos,I);
end;

% Processing all expressions


Atf = []; bf = []; 
for i = 1:sos.expr.num
    Atf = [Atf, sos.expr.At{i}];
    bf = [bf; sos.expr.b{i}];
end;

% Processing all variables
[At,b,K,RR] = processvars(sos,Atf,bf);

% Objective function
c = sparse(size(At,1),1);

%% Added by PAP, for compatibility with MATLAB 6.5
if isempty(sos.objective);
	sos.objective = zeros(size(c(1:sos.var.idx{end}-1)));
end
%% End added stuff

c(1:sos.var.idx{end}-1) = c(1:sos.var.idx{end}-1) + sos.objective;       % 01/07/02
c = RR'*c;

pars = options.params;

%perform facial reduction using FP's algorithm (JA 5/1/16)
if isfield(options,'frlib')
	At_full = At;   c_full = c; %Need duplicate copy if applying facial reduction as reduced matrices overwrite these
	b_full = b;     K_full = K;
	size_At_full = size(At_full);
	
	[prg_primal] = frlib_pre(options.frlib,At',b,c,K); %interface with frlib
	At = prg_primal.A';  %reduced SDP matrices
	b = prg_primal.b;
	c = prg_primal.c';
	K = prg_primal.K;
	size_AT_solved = size(At);
else
	size_At_full = size(At);
end


if (options.vsdp)
  size_At = size(At);
  disp(['Size: ' num2str(size_At)]);
  disp([' ']);

  startintlab;
  vsdpinit('clear');
  vsdpinit(lower(options.solver));
  [objt,xt,yt,zt,infovsdp] = mysdps(At,b,c,K);
  
  x = xt;
  y = yt;
  info.pinf = mod(infovsdp,2);
  info.dinf = floor(infovsdp/2);
  info.fL = vsdplow(At,b,c,K,xt,yt,zt);
  info.fU = vsdpup(At,b,c,K,xt,yt,zt);
elseif strcmp(lower(options.solver),'sedumi')
  % SeDuMi in action
  size_At = size(At);
  disp(['Size: ' num2str(size_At)]);
  disp([' ']);
  
  [x,y,info] = sedumi(At,b,c,K,pars);
elseif strcmp(lower(options.solver),'cdcs')
	% CDCS in action
	size_At = size(At);
	disp(['Size: ' num2str(size_At)]);
	disp([' ']);
	params.maxIter = 50000;
	%params.solver = 'sos';
	%params.relTol = 1e-5;
	[x,y,z,info] = cdcs(At,b,c,K,params);
	info.pinf = 0;
	info.dinf = 0;
	info.numerr = 0;
	if info.problem == 1
		info.pinf = 1;
	elseif info.problem == 2
		info.dinf = 1;
	elseif info.problem == 4
		info.numerr = 1;
	end
elseif strcmp(lower(options.solver),'sdpt3')
	% SDPT3 in action
	smallblkdim = 60;
	save sostoolsdata_forSDPT3 At b c K smallblkdim;
	[blk,At2,C2,b2] = read_sedumi('sostoolsdata_forSDPT3.mat');
	delete sostoolsdata_forSDPT3.mat;
	[obj,X,y,Z,infoSDPT] = sqlp(blk,At2,C2,b2,pars);
	%size_AT_solved = size(At);
	x = zeros(length(c),1);
	cellidx = 1;
	if K.f ~= 0
		x(1:K.f) = X{1}(:);
		cellidx = 2;
	end;
    if K.s(1) ~= 0
		idxX = 1;
		idx = K.f+1;
		smblkdim = 100;
		deblkidx = find(K.s > smblkdim);
		spblkidx = find(K.s <= smblkdim);
		blknnz = [0 cumsum(K.s.*K.s)];
		for i = deblkidx
			dummy = X{cellidx};
			x(idx+blknnz(i):idx+blknnz(i+1)-1) = dummy(:);
			cellidx = cellidx+1;
		end;
		for i = spblkidx
			dummy = X{cellidx}(idxX:idxX+K.s(i)-1,idxX:idxX+K.s(i)-1);
			x(idx+blknnz(i):idx+blknnz(i+1)-1) = dummy(:);
			idxX = idxX+K.s(i);
		end;
	end;
	info.cpusec = infoSDPT.cputime;
	info.iter = infoSDPT.iter;
	if infoSDPT.termcode == 1
		info.pinf = 1;
	else
		info.pinf = (infoSDPT.pinfeas>0.1);
	end;
	if infoSDPT.termcode == 2
		info.dinf = 1;
	else
		info.dinf = (infoSDPT.dinfeas>0.1);
	end;
	if infoSDPT.termcode<= 0
		info.numerr = infoSDPT.termcode;
	else
		info.numerr = 0;
	end;	
elseif strcmp(lower(options.solver),'csdp') %6/6/13 JA CSDP interface
	%CSDP in action
	if exist('solver_options.params')
		pars = options.params;
	else
		pars.objtol = 1e-9;
		pars.printlevel = 1;
    end
	if (isfield(K,'f')) %Convert free vars to non-negative LP vars
		n_free = K.f;
		[A,b,c,K] = convertf(At,b,c,K); %K.f set to zero
		At = A';
    end
	c = full(c);
	[x,y,z,info_csdp] = csdp(At,b,c,K,pars);  %JA updated handling of info flag
	c = sparse(c);
	% 7/6/13 JA Remove extra entries from x corresponding to LP vars
	if (isfield(K,'f')) %Convert free vars to non-negative LP vars
		index = [n_free+1:2*n_free];
		x(1:n_free) = x(1:n_free)-x(index);
		x(index) = [];
		At(index,:)=[];
		c(index) = [];
    end
	switch info_csdp
		case {0,3}
			info.pinf = 0;
			info.dinf = 0;
        case 1
			info.pinf = 1;
			info.dinf = 0;
        case 2
			info.pinf = 0;
			info.dinf = 1;
		otherwise
			info.pinf = 1;
			info.dinf = 1;
	end
elseif strcmp(lower(options.solver),'sdpnal') %6/11/13 JA SDPNAL interface
	% SDPNAL in action
	save sostoolsdata_forSDPNAL At b c K;
	[blk,At2,C2,b2] = read_sedumi('sostoolsdata_forSDPNAL.mat');
	delete sostoolsdata_forSDPNAL.mat;
	pars.maxiter = 100;
	try
		[obj,X,y,Z,infonal,runhist] = sdpnal(blk,At2,C2,b2,pars); %run history not returned;
	catch
		[obj,X,y,Z,infonal,runhist] = sdpnal(blk,At2,C2,b2,pars); %run history not returned;
		info = [];
	end
	x = zeros(length(c),1);
	cellidx = 1;
	if K.f ~= 0
		x(1:K.f) = X{1}(:);
		cellidx = 2;
	end;
    if K.s(1) ~= 0
		idxX = 1;
		idx = K.f+1;
		smblkdim = 100;
		deblkidx = find(K.s > smblkdim);
		spblkidx = find(K.s <= smblkdim);
		blknnz = [0 cumsum(K.s.*K.s)];
		for i = deblkidx
			dummy = X{cellidx};
			x(idx+blknnz(i):idx+blknnz(i+1)-1) = dummy(:);
			cellidx = cellidx+1;
		end;
		for i = spblkidx
			dummy = X{cellidx}(idxX:idxX+K.s(i)-1,idxX:idxX+K.s(i)-1);
			x(idx+blknnz(i):idx+blknnz(i+1)-1) = dummy(:);
			idxX = idxX+K.s(i);
		end;
	end;
	info.iter = infonal.iter;
	info.pinf = (infonal.pinfeas>0.1);
	info.dinf = (infonal.dinfeas>0.1);
	info.msg = infonal.msg;
elseif strcmp(lower(options.solver),'sdpnalplus') %6/11/13 JA SDPNALPLUS interface
	% SDPNALPLUS in action
	smallblkdim = 50;
	save sostoolsdata_forSDPNAL At b c K smallblkdim;
	[blk,At2,C2,b2] = read_sedumi('sostoolsdata_forSDPNAL.mat');
	delete sostoolsdata_forSDPNAL.mat;
	pars.maxiter = 100;
	try
		[obj,X,s,y,S,Z,y2,v,info,runhist] = sdpnalplus(blk,At2,C2,b2,[],[],[],[],[],pars); %run history not returned;
	catch
		[obj,X,s,y,S,Z,y2,v,info,runhist] = sdpnalplus(blk,At2,C2,b2,[],[],[],[],[],pars); %run history not returned;
		info = [];
	end
	x = zeros(length(c),1);
	cellidx = 1;
	if K.f ~= 0
		x(1:K.f) = X{1}(:);
		cellidx = 2;
	end;
    if K.s(1) ~= 0
		idxX = 1;
		idx = K.f+1;
		smblkdim = 100;
		deblkidx = find(K.s > smblkdim);
		spblkidx = find(K.s <= smblkdim);
		blknnz = [0 cumsum(K.s.*K.s)];
		for i = deblkidx
			dummy = X{cellidx};
			x(idx+blknnz(i):idx+blknnz(i+1)-1) = dummy(:);
			cellidx = cellidx+1;
		end;
		for i = spblkidx
			dummy = X{cellidx}(idxX:idxX+K.s(i)-1,idxX:idxX+K.s(i)-1);
			x(idx+blknnz(i):idx+blknnz(i+1)-1) = dummy(:);
			idxX = idxX+K.s(i);
		end;
	end;
	if ~isempty(info)
		if info.etaRp>1e-6||info.etaRd>1e-6
			info.dinf=1;
			info.pinf=1;
		else
			info.dinf=0;
			info.pinf=0;
		end;
	else
		info.dinf=1;
		info.pinf=1;
	end
elseif strcmp(lower(options.solver),'sdpa')
	% SDPA in action
	disp(['Size: ' num2str(size(At))]);
	disp([' ']);
	[x,y,info]=sedumiwrap(At',b,c,K,[],pars);
	
	if strcmp(info.phasevalue,'pdOPT')|| strcmp(info.phasevalue,'pdFEAS')%primal and dual optimal or feasible
		info.dinf=0;
		info.pinf=0;
	elseif strcmp(info.phasevalue,'pdINF') %primal and dual infeasible
		info.dinf=1;
		info.pinf=1;
	elseif strcmp(info.phasevalue,'pINF_dFEAS') % primal infeasible, dual infeasible
       info.dinf=0;
       info.pinf=1;
	elseif strcmp(info.phasevalue,'pFEAS_dINF') % dual infesaible, primal feasible
       info.dinf=1;
       info.pinf=0;       
	elseif strcmp(info.phasevalue,'noINFO') || strcmp(info.phasevalue,'pFEAS') || strcmp(info.phasevalue,'dFEAS')% max. iterations exceeded no idea if feasible
		if info.primalError < 1e-6 || strcmp(info.phasevalue,'pFEAS')
			info.pinf = 0;
		else
		   info.pinf = 1;
       end
	   if info.dualError < 1e-6 || strcmp(info.phasevalue,'dFEAS')
		   info.dinf = 0;
       else
		   info.dinf = 1;
	   end
	end;
end;


%JA frlib post-process
if isfield(options,'frlib') && size_AT_solved(1) < size_At_full(1) %frlib applied and reduction constructed
	dim_b = length(b_full);
	[x,y] = frlib_post(prg_primal,x,y,dim_b);
	At = At_full;  %Restore original matrices
	b = b_full;
	c = c_full;
	K = K_full;
end

disp([' ']);
disp(['Residual norm: ' num2str(norm(At'*x-b))]);
disp([' ']);
sos.solinfo.x = x;
sos.solinfo.y = y;
sos.solinfo.RRx = RR*x;
sos.solinfo.RRy = RR*(c-At*y);    % inv(RR') = RR
sos.solinfo.info = info;
sos.solinfo.solverOptions = options;
disp(info)


%return;

% Constructing the (primal and dual) solution vectors and matrices
% If you want to have them, comment/delete the return command above.
% In the future version, these primal and dual solutions will be computed only
% when they are needed. We don't want to store redundant info.

for i = 1:sos.var.num
	switch sos.var.type{i}
		case 'poly'
			sos.solinfo.var.primal{i} = sos.solinfo.RRx(sos.var.idx{i}:sos.var.idx{i+1}-1);
            sos.solinfo.var.dual{i} = sos.solinfo.RRy(sos.var.idx{i}:sos.var.idx{i+1}-1);
		case 'sos'
			primaltemp = sos.solinfo.RRx(sos.var.idx{i}:sos.var.idx{i+1}-1);
			dualtemp = sos.solinfo.RRy(sos.var.idx{i}:sos.var.idx{i+1}-1);
			sos.solinfo.var.primal{i} = reshape(primaltemp,sqrt(length(primaltemp)),sqrt(length(primaltemp)));
			sos.solinfo.var.dual{i} = reshape(dualtemp,sqrt(length(dualtemp)),sqrt(length(dualtemp)));
	end;
end;

for i = 1:sos.extravar.num
	primaltemp = sos.solinfo.RRx(sos.extravar.idx{i}:sos.extravar.idx{i+1}-1);
	dualtemp = sos.solinfo.RRy(sos.extravar.idx{i}:sos.extravar.idx{i+1}-1);
	sos.solinfo.extravar.primal{i} = reshape(primaltemp,sqrt(length(primaltemp)),sqrt(length(primaltemp)));
	sos.solinfo.extravar.dual{i} = reshape(dualtemp,sqrt(length(dualtemp)),sqrt(length(dualtemp)));
end;

sos.solinfo.decvar.primal = sos.solinfo.RRx(1:sos.var.idx{1}-1);
sos.solinfo.decvar.dual = sos.solinfo.RRy(1:sos.var.idx{1}-1);



% ====================================================================================
function sos = addextrasosvar(sos,I)
% Adding slack SOS variables to inequalities


for i = I
	numstates = size(sos.expr.Z{i},2);%GV&JA 6/12/2013
	% Creating extra variables
    maxdeg = full(max(sum(sos.expr.Z{i},2))); 
	mindeg = full(min(sum(sos.expr.Z{i},2)));
	Z = monomials(numstates,[floor(mindeg/2):ceil(maxdeg/2)]);
	%disp(['Original : ',num2str(size(Z,1))]);
	
	% Discarding unnecessary monomials
	maxdegree = sparse(max(sos.expr.Z{i},[],1)/2);
	mindegree = sparse(min(sos.expr.Z{i},[],1)/2);
	
	Zdummy1 = bsxfun(@minus,maxdegree,Z);
	Zdummy2 = bsxfun(@minus,Z,mindegree);
	[I,~] = find([Zdummy1 Zdummy2]<0);
	IND = setdiff(1:size(Z,1),I,'stable');
	Z = Z(IND,:);
	
	%GV 27/06/2014 - replaced the code below by the above, where the indexes
	%are used to update the matrix of monomials. Matrices maxdegree and
	%mindegree were set to be sparse.
	
	%     Iout = [];indI = 0;%GV 27/06/2014 checking correctness
	%     Z = monomials(numstates,[floor(mindeg/2):ceil(maxdeg/2)]);%GV 27/06/2014 checking correctness
	%     j = 1;
	%     while (j <= size(Z,1))
	%         indI = indI+1;%GV 27/06/2014 checking correctness
	%         Zdummy1 = maxdegree-Z(j,:);
	%         Zdummy2 = Z(j,:)-mindegree;
	%         idx = find([Zdummy1, Zdummy2]<0);
	%         if ~isempty(idx)
	%             Iout = [Iout; indI];%GV 27/06/2014 checking correctness
	%             Z = [Z(1:j-1,:); Z(j+1:end,:)];
    %         else
	%             j = j+1;
	%         end;
	%     end;
	%     sparse(unique(I,'legacy')-Iout)%GV 27/06/2014 checking correctness
	
	
	%disp(['Optimized : ',num2str(size(Z,1))]);
	
	% Convex hull algorithm
	if strcmp(sos.expr.type{i},'sparse')
		Z2 = sos.expr.Z{i}/2;
		Z = inconvhull(full(Z),full(Z2));
		Z = makesparse(Z);
		%disp(['Optimized again : ',num2str(size(Z,1))]);
	end;
	
	if strcmp(sos.expr.type{i},'sparsemultipartite')
		Z2 = sos.expr.Z{i}/2;
		info2 = sos.expr.multipart{i};%the vectors of independent variables
		sizeinfo2m = length(info2);
		vecindex = [];
		for indm = 1:sizeinfo2m%for each set of independent variables
			sizeinfo2n(indm) = length(info2{indm});
			for indn = 1:sizeinfo2n(indm)
				
				if isfield(sos,'symvartable')%
					varcheckindex = find(info2{indm}(indn)==sos.symvartable);
					if ~isempty(varcheckindex)
						vecindex{indm}(indn) = varcheckindex;
					else
						vecindex{indm}(indn) = length(info2{1})+find(info2{indm}(indn)==sos.varmat.symvartable);%GV&JA 6/12/2013
					end
					
				else
					% PJS 9/12/13: Update code to handle polynomial objects
					var = info2{indm}(indn);
					cvartable = char(sos.varmat.vartable);
					
					if ispvar(var)
						% Convert to string representation
						var = var.varname;
                    end
					varcheckindex = find(strcmp(var,sos.vartable));
					if ~isempty(varcheckindex)
						vecindex{indm}(indn) = varcheckindex;
					else
						vecindex{indm}(indn) = length(info2{1}) + find(strcmp(var,cvartable));
					end
					
					% PJS 9/12/13: Original Code to handle polynomial objects
					%vecindex{indm}(indn) = find(strcmp(info2{indm}(indn).varname,sos.vartable));
				end;
			end
        end
		Z = sparsemultipart(full(Z),full(Z2),vecindex);
		Z = makesparse(Z);
	end;
	
	
	
	dimp = size(sos.expr.b{i},2);
	
	% Adding slack variables
	sos.extravar.num = sos.extravar.num + 1;
	var = sos.extravar.num;
	sos.extravar.Z{var} = makesparse(Z);
	[T,ZZ] = getconstraint(Z);
	sos.extravar.ZZ{var} = ZZ;
	sos.extravar.T{var} = T';
	%sos.extravar.idx{var+1} = sos.extravar.idx{var}+size(Z,1)^2;%GVcomment the next slack variable starts in the column i+dim(Z)^2 - the elements of the vectorized square matrix
	
	
	sos.extravar.idx{var+1} = sos.extravar.idx{var}+(size(Z,1)*dimp)^2;
	for j = 1:sos.expr.num
		sos.expr.At{j} = [sos.expr.At{j}; ...
			sparse(size(sos.extravar.T{var},1)*dimp^2,size(sos.expr.At{j},2))];
	end
	
	ZZ = flipud(ZZ);
	T = flipud(T);
	
	Zcheck = sos.expr.Z{i};
	%this is for the matrix case
	
	
	
	
	if dimp==1
		% JFS 6/3/2003: Ensure correct size:
		pc.Z = sos.extravar.ZZ{var};
		pc.F = -speye(size(pc.Z,1));
		[R1,R2,newZ] = findcommonZ(sos.expr.Z{i},pc.Z);
		% JFS 6/3/2003: Ensure correct size:
		
		if isempty(sos.expr.At{i})
			sos.expr.At{i} = sparse(size(sos.expr.At{i},1),size(R1,1));
        end
		%------------
        sos.expr.At{i} = sos.expr.At{i}*R1;
		lidx = sos.extravar.idx{var};
		uidx = sos.extravar.idx{var+1}-1;
        sos.expr.At{i}(lidx:uidx,:) = sos.expr.At{i}(lidx:uidx,:) - sos.extravar.T{var}*pc.F*R2;
        sos.expr.b{i} = R1'*sos.expr.b{i};
        sos.expr.Z{i} = newZ;
        
    else
        
        [R1,R2,Znew] = findcommonZ(Zcheck,ZZ);
        
        R1 = fliplr(R1);
        R2 = fliplr(R2);
        Znew = flipud(Znew);
        
        R1sum = sum(R1,1);
        T = R2'*T;
        
        ii = 1;
        sig_ZZ = size(ZZ,1);
        sig_Z = size(Z,1);
        sig_Znew = size(Znew,1);
        
        Tf = sparse(dimp^2*sig_Znew,(dimp*sig_Z)^2);
        Sv = sparse(sig_Znew*dimp^2,1);
        for j = 1:sig_Znew
            Mt0 = sparse(dimp,dimp*sig_Z^2);
            for k = 1:sig_Z
                Mt0(:, (dimp*sig_Z)*(k-1)+1:(dimp*sig_Z)*k) = kron(eye(dimp),T(j,(sig_Z)*(k-1)+1:(sig_Z)*k));
            end
            Tf((j-1)*dimp^2+1:j*dimp^2,:) = kron(eye(dimp),Mt0);
            
            if R1sum(j)==1
                Sv((j-1)*dimp^2+1:j*dimp^2)= reshape(sos.expr.b{i}( dimp*(ii-1)+1:dimp*ii,:)',dimp^2,1);
                if ii<size(Zcheck,1)
                    ii = ii+1;
                end
            else
                sos.expr.At{i} = [ sos.expr.At{i}(:,1:(j-1)*dimp^2) sparse(size(sos.expr.At{i},1),dimp^2) sos.expr.At{i}(:,(j-1)*dimp^2+1:end)];
            end
        end
        
        lidx = sos.extravar.idx{var};
        uidx = sos.extravar.idx{var+1}-1;
        sos.expr.At{i}(lidx:uidx,:) =  Tf';
        sos.expr.b{i} =  Sv;
        
    end
end;

% ====================================================================================
function sos = addextrasosvar2(sos,I)
% Adding slack SOS variables type II 

numstates = size(sos.expr.Z{1},2);
for i = I
    % Creating extra variable
    maxdeg = full(max(sum(sos.expr.Z{i},2)));
    mindeg = full(min(sum(sos.expr.Z{i},2)));
    Z = monomials(numstates,[floor(mindeg/2):ceil(maxdeg/2)]);
    
    % Discarding unnecessary monomials
    maxdegree = max(sos.expr.Z{i},[],1)/2;
    mindegree = min(sos.expr.Z{i},[],1)/2;
    j = 1;
    while (j <= size(Z,1))
        Zdummy1 = maxdegree-Z(j,:);
        Zdummy2 = Z(j,:)-mindegree;
        idx = find([Zdummy1, Zdummy2]<0);
        if ~isempty(idx)
            Z = [Z(1:j-1,:); Z(j+1:end,:)];
        else
            j = j+1;
        end;  
    end;    
    
    % Add the variables
    
    for k = 0:1
        
    sos.extravar.num = sos.extravar.num + 1;
    var = sos.extravar.num;
    sos.extravar.Z{sos.extravar.num} = makesparse(Z);
    [T,ZZ] = getconstraint(Z);
    sos.extravar.ZZ{var} = ZZ;
    sos.extravar.T{var} = T';
    sos.extravar.idx{var+1} = sos.extravar.idx{var}+size(Z,1)^2;
    for j = 1:sos.expr.num
        sos.expr.At{j} = [sos.expr.At{j}; ...
                sparse(size(sos.extravar.T{var},1),size(sos.expr.At{j},2))];
    end;
    
    % Modifying expression
    degoffset = [k sparse(1,numstates-1)];
    pc.Z = sos.extravar.ZZ{var} + degoffset(ones(size(sos.extravar.ZZ{var},1),1),:);
    pc.F = -speye(size(pc.Z,1));
    [R1,R2,newZ] = findcommonZ(sos.expr.Z{i},pc.Z);
    % JFS 6/3/2003: Ensure correct size:
    if isempty(sos.expr.At{i})
       sos.expr.At{i} = sparse(size(sos.expr.At{i},1),size(R1,1));
    end
    %------------
    sos.expr.At{i} = sos.expr.At{i}*R1;
    lidx = sos.extravar.idx{var};
    uidx = sos.extravar.idx{var+1}-1;
    sos.expr.At{i}(lidx:uidx,:) = sos.expr.At{i}(lidx:uidx,:) - sos.extravar.T{var}*pc.F*R2;
    sos.expr.b{i} = R1'*sos.expr.b{i};
    sos.expr.Z{i} = newZ;
    
    Z = Z(find(Z<maxdegree));    % Discard the unnecessary monomial for the second variable
    
    end;
    
end;

% ====================================================================================
function [At,b,K,RR] = processvars(sos,Atf,bf)
% Processing all variables

% Decision variables
K.s = [];
K.f = sos.var.idx{1}-1;
RR = speye(K.f);


% Polynomial and SOS variables
for i = 1:sos.var.num
    switch sos.var.type{i}
    case 'poly'
        sizeX = sos.var.idx{i+1}-sos.var.idx{i};
        startidx = sos.var.idx{i};
        RR = spantiblkdiag(RR,speye(sizeX));
        K.f = sizeX+K.f;
    case 'sos'
        sizeX = sqrt(sos.var.idx{i+1}-sos.var.idx{i});
        startidx = sos.var.idx{i};
        RR = spblkdiag(RR,speye(sizeX^2));
        K.s = [K.s sizeX];
    end;
end;

for i = 1:sos.extravar.num
    sizeX = sqrt(sos.extravar.idx{i+1}-sos.extravar.idx{i});
    startidx = sos.extravar.idx{i};
    RR = spblkdiag(RR,speye(sizeX^2));
    K.s = [K.s sizeX];
end;

At = RR'*Atf;

b = bf;

