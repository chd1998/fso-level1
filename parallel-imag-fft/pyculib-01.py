import numpy as np
import scipy.sparse.linalg
import pyculib

handle = pyculib.sparse.Sparse()
dtype = np.float32
m = n = 3
trans = 'N'


# Initialize the CSR matrix on the host and GPU.
row = np.array([0, 0, 0, 1, 1, 2])
col = np.array([0, 1, 2, 1, 2, 2])
data = np.array([0.431663, 0.955176, 0.925239, 0.0283651, 0.569277, 0.48015], dtype=dtype)

csrMatrixCpu = scipy.sparse.csr_matrix((data, (row, col)), shape=(m, n))
csrMatrixGpu = pyculib.sparse.csr_matrix((data, (row, col)), shape=(m, n))

print(csrMatrixCpu)
print(csrMatrixCpu.todense())

# Perform the analysis step on the GPU.
nnz = csrMatrixGpu.nnz
csrVal = csrMatrixGpu.data
csrRowPtr = csrMatrixGpu.indptr
csrColInd = csrMatrixGpu.indices

descr = handle.matdescr(0, 'N', 'U', 'G')
info = handle.csrsv_analysis(trans, m, nnz, descr, csrVal, csrRowPtr, csrColInd)


# Initialize the right-hand side of the system.
alpha = 1.0
rightHandSide = np.array([0.48200423, 0.39379725, 0.75963706], dtype=dtype)
gpuResult = np.zeros(m, dtype=dtype)


# Solve the system on the GPU and on the CPU.
handle.csrsv_solve(trans, m, alpha, descr, csrVal, csrRowPtr, csrColInd, info, rightHandSide, gpuResult)
cpuResult = scipy.sparse.linalg.dsolve.spsolve(csrMatrixCpu, rightHandSide, use_umfpack=False)

cpuDense = np.linalg.solve(csrMatrixCpu.todense(), rightHandSide)

print('gpu result = ' + str(gpuResult))
print('cpu result = ' + str(cpuResult))
print('cpu result = ' + str(cpuDense))(pyculib_example) 