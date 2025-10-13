import assert from 'assert'
import { Retry } from ".Retry"
import { Logger } from './logger/Logger'
const log = new Logger()

class DecoratorTest {

    @Retry.retry()
    async memberMethod(lambda: Function): Promise<any> {
        return new Promise(async (resolve, reject) => {
            try {
                if (lambda() < 3)
                    throw new Error("errored")
                resolve(123)
            } catch (ex) {
                reject(ex)
            }
        })
    }

}


describe("Tests Retry Util", function () {


    it("Tests the retry decorator", async () => new Promise(async (resolve, reject) => {
        try {
            let dt = new DecoratorTest()
            let retries = 0;

            let result = await dt.memberMethod(() => {
                log.debug(`retries: ${retries}`)
                retries++
                return retries
            })

            assert.strictEqual(result, 123)

            resolve()

        } catch (ex) {
            reject(ex)
        }
    }));

    it("Tests basic retry, 2 try pass", async () => new Promise(async (resolve, reject) => {
        try {

            let result = await Retry.do({
                intervals: [1000, 1000, 1000]
            },
                (retryCount: number) => new Promise(async (resolve: Function, reject: Function) => {
                    try {
                        if (retryCount < 2)
                            throw new Error("Error during retry.")
                        resolve(123)
                    } catch (ex) {
                        reject(ex)
                    }
                }))

            assert.strictEqual(123, result)

            resolve()
        } catch (ex) {
            reject(ex)
        }
    }))

    it("Tests basic retry, 4 try fail", async () => new Promise(async (resolve, reject) => {
        try {

            let result = await Retry.do({
                intervals: [1000, 1000, 1000]
            },
                (retryCount: number) => new Promise(async (resolve: Function, reject: Function) => {
                    try {
                        throw new Error("Error during retry: " + retryCount)
                    } catch (ex) {
                        reject(ex)
                    }
                }))

            reject("An error was expected.")
        } catch (ex: any) {
            assert.ok(ex.message.indexOf("Error during retry") != -1, "Expected to fnd Error during retry in message.")
            resolve()
        }
    }))

    it("Does not retry accepted errors.", async () => new Promise(async (resolve, reject) => {
        class AcceptedError extends Error {
            constructor(...p: any) {
                super(...p)
            }
        }
        let retries: number = 0;
        try {
            let result = await Retry.do({
                acceptedErrors: [AcceptedError],
                intervals: [1000, 1000, 1000]
            },
                (retryCount: number) => new Promise(async (resolve: Function, reject: Function) => {
                    retries++
                    try {
                        throw new AcceptedError("An accepted error should not retry.")
                    } catch (ex: any) {
                        reject(ex)
                    }
                }))

            reject("An AcceptedError message is expected.")
        } catch (ex: any) {
            assert.strictEqual(1, retries, "No retries occurred for accepted errors.")
            assert.ok(ex instanceof AcceptedError, "An AcceptedError should be thrown without retries.")
            resolve()
        }
    }))


})