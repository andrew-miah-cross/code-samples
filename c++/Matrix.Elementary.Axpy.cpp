
namespace ml {

	template <typename T>
	inline void Matrix<T>::AxpyInPlaceSecond(const uint32_t& p, const uint32_t& q, const T& alpha) {
		for (uint32_t i = 0; i < RowCount(); i++)
			(*this)[i][q] += (*this)[i][p] * alpha;
	}

	template <typename T>
	inline void Matrix<T>::AxpyInPlaceFirst(const uint32_t& p, const uint32_t& q, const T& alpha) {
		for (uint32_t j = 0; j < ColumnCount(); j++)
			(*this)[p][j] += (*this)[q][j] * alpha;
	}

}