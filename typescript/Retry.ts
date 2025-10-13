
export class Retry {

    /**
     * Decorator: retry
     * 
     * @param acceptedErrors    [].  Any array of classes derived from Error that will not be retried. 
     * @param intervals         [1000, 1000, 1000, 3000, 10000, 15000, 30000, 15000, 15000, 15000, 15000, 15000]. An array of millisecond intervals between retries.  
     * @returns Promise<any> 
     */
    static retry(
        acceptedErrors: Error[] = [],
        intervals: number[] = [1000, 1000, 1000, 3000, 10000, 15000, 30000, 15000, 15000, 15000, 15000, 15000]
    ) {
        return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
            const originalMethod = descriptor.value
            descriptor.value = async function (...args: any[]) {
                return URetry.do({
                    acceptedErrors: acceptedErrors,
                    intervals: intervals
                },
                    (retryCount: number) => new Promise(async (resolve: Function, reject: Function) => {
                        try {
                            let result: any = await originalMethod.apply(this, args)
                            resolve(result)
                        } catch (ex) {
                            reject(ex)
                        }
                    }))
            }
        }
    }

}