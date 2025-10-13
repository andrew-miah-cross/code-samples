using MathNet.Numerics.LinearAlgebra;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Classifiers
{
    public partial class MatrixUtil
    {

        public static Matrix<Double> CholeskyFactorization(Matrix<Double> A)
        {
            Matrix<Double> T = Matrix<Double>.Build.DenseIdentity(A.RowCount);

            T[0, 0] = Math.Sqrt(A[0, 0]);

            for (int j = 1; j < A.ColumnCount; j++)
            {
                T[0, j] = A[0, j] / T[0, 0];
            }

            for (int i = 1; i < A.RowCount; i++)
            {
                double t = A[i, i];
                for (int k = 0; k < i; k++)
                    t -= T[k, i] * T[k, i];
                T[i, i] = Math.Sqrt(t);

                for (int j = i + 1; j < A.ColumnCount; j++)
                {
                    t = A[i, j];
                    for (int k = 0; k < i; k++)
                        t -= T[k, i] * T[k, j];
                    T[i, j] = t / T[i, i];
                }

            }
        }


    }
}
