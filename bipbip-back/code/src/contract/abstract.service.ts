export default abstract class AbstractService {
  protected abstract executeProcess(params: unknown): Promise<object>;

  public async process(params: unknown): Promise<object> {
    const result = await this.executeProcess(params);
    return result;
  }
}
