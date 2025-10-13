using MathNet.Numerics.LinearAlgebra;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ml.neural
{
    public class Activations
    {
        public enum Type {
            None,
            Linear,
            Sigmoid,
            Tanh,
            ReLu,
            Softmax
        };

        static IDictionary<Type, Func<Vector<double>,Vector<double>>> activationMap = new Dictionary<Type, Func<Vector<double>,Vector<double>>>
        {
            { Type.Linear,LinearActivation },
            { Type.Sigmoid,SigmoidActivation },
            { Type.Tanh,TanhActivation },
            { Type.ReLu,ReLuActivation },
            { Type.Softmax,SoftmaxActivation }
        };

        static IDictionary<Type, Func<Vector<double>, Vector<double>>> derivativeActivationMap = new Dictionary<Type, Func<Vector<double>, Vector<double>>>
        {
            { Type.Linear,LinearDerivative },
            { Type.Sigmoid,SigmoidDerivative },
            { Type.Tanh,TanhDerivative },
            { Type.ReLu,ReLuDerivative },
            { Type.Softmax,SoftmaxActivationDerivative }
        };

        public static Vector<double> Invoke(Type activationType,Vector<Double> v)
        {
            return activationMap[activationType].Invoke(v);
        }
        public static Vector<double> InvokeDerivative(Type activationType, Vector<Double> v)
        {
            return derivativeActivationMap[activationType].Invoke(v);
        }

        // Activations

        public static Vector<Double> LinearActivation(Vector<Double> input)
        {
            return input.Map( v => v );
        }

        public static Vector<Double> LinearDerivative(Vector<Double> input)
        {
            return Vector<Double>.Build.Dense(input.Count, 1);
        }

        public static Vector<Double> SigmoidActivation(Vector<Double> input)
        {
            return input.Map( v => 1.0 / (1.0 + Math.Exp(-v)) );
        }

        public static Vector<Double> SigmoidDerivative(Vector<Double> input)
        {
            return input.Map( v => v * (1.0 - v) );
        }

        public static Vector<Double> TanhActivation(Vector<Double> input)
        {
            return input.Map( v => Math.Exp(v) - Math.Exp(-v) / (Math.Exp(v) + Math.Exp(-v)) );
        }

        public static Vector<Double> TanhDerivative(Vector<Double> input)
        {
            return input.Map( v => 1 - Math.Pow(v, 2) );
        }

        public static Vector<Double> ReLuActivation(Vector<Double> input)
        {
            return input.Map( v => Math.Max(0, v) );
        }

        public static Vector<Double> ReLuDerivative(Vector<Double> input)
        {
            return input.Map(v => v <= 0 ? 0.0 : 1.0);
        }

        public static Vector<Double> SoftmaxActivation(Vector<Double> input)
        {
            Vector<Double> result = Vector<Double>.Build.Dense(input.Count);

            for (int k = 0; k < input.Count; k++)
            {
                double sum = 0;
                for (int g = 0; g < input.Count; g++)
                        sum += Math.Exp(input[g]);
                sum += Double.Epsilon;
                result[k] = Math.Exp(input[k]) / sum;
            }

            return result;
        }

        public static Vector<Double> SoftmaxActivationDerivative(Vector<Double> input)
        {
            return input.Map(v => v * (1 - v));
        }

    }
}
