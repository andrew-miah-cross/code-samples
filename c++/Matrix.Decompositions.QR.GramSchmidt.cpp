
namespace ml {

	template <typename T>
	void Matrix<T>::QRDecompositionGrammSchmidt(Matrix<T>& Q, Matrix<T>& R) const {
		Matrix<T> A(*this, true);

		if (A.RowCount() != A.ColumnCount()) {
			throw MatrixNonSquareException<T>(A);
		}

		if (!IsFullRank()) {
			throw MatrixSingularException<T>(*this, "Singular matrix, QR cannot be found via Gram Schmidt.");
		}

		Matrix<T> result(A, true);
		result.SetRow(0, A.Row(0) / A.Row(0).L2Norm());

		for (uint32_t k = 1; k < A.RowCount(); k++)
		{
			Vector<T> x_k_previous = result.Row(k - 1);

			for (uint32_t j = k; j < A.ColumnCount(); j++)
			{
				Vector<T> x_j = result.Row(j);
				x_j = x_j - (x_k_previous * x_k_previous.InnerProduct(x_j));
				result.SetRow(j, x_j);
			}

			if (result.Row(k).L2Norm() < FLT_EPSILON )
				throw MatrixIllConditionedException<T>(result);
	
			result.SetRow(k, result.Row(k) / result.Row(k).L2Norm());
		}

		Q = result;
		R = A * Q.Transposed();
		Q = Q.Transposed();
		R = R.Transposed();

	}


}